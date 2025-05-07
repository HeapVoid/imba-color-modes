export class ColorModes

	def constructor
		document.documentElement.style.colorScheme = active

	get light
		return preset == 'light'

	set light value\Boolean
		preset = 'light' if value

	get dark
		return preset == 'dark'
	
	set dark value\Boolean
		preset = 'dark' if value

	get auto
		return preset == 'system'
	
	set auto value\Boolean
		preset = 'system' if value

	get active
		return preset == 'system' ? system : window.localStorage.getItem('imba-color-modes')

	set active value\string
		preset = value

	get system
		window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
	
	get preset
		const mode = window.localStorage.getItem('imba-color-modes')
		return mode in ['light', 'dark'] ? mode : 'system'

	set preset value\string
		const mode = value in ['light', 'dark'] ? value : 'system'
		window.localStorage.setItem('imba-color-modes', mode)
		document.documentElement.style.colorScheme = active

	def toggle
		if active == 'dark' then light = true else dark = true

# --------------------------------------------------
# --------------------------------------------------
# Palletes and color mixing
# --------------------------------------------------
# --------------------------------------------------

# --------------------------------------------------
# Helper functions
# --------------------------------------------------

# Helper: Convert hex to RGB
def hexToRgb hex
	hex = hex.replace(/^#/, '')
	hex = hex.split('').map(do(c) c + c).join('') if hex.length === 3
	const bigint = parseInt(hex, 16)
	return
		r: (bigint >> 16) & 255
		g: (bigint >> 8) & 255
		b: bigint & 255

# Helper: Convert RGB to hex
def rgbToHex r, g, b
	const toHex = do(c) c.toString(16).padStart(2, '0')
	return "#{toHex(r)}{toHex(g)}{toHex(b)}"

# Helper: sRGB to linear RGB
def srgbToLinear c
	c /= 255
	return (c <= 0.04045) ? (c / 12.92) : Math.pow((c + 0.055) / 1.055, 2.4)

# Helper: Linear RGB to sRGB
def linearToSrgb c
	return (c <= 0.0031308) ? (12.92 * c) : (1.055 * Math.pow(c, 1 / 2.4) - 0.055)

# Helper: Linear RGB to Oklab
def linearRgbToOklab r, g, b
	const l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	const m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	const s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

	const l_ = Math.cbrt(l)
	const m_ = Math.cbrt(m)
	const s_ = Math.cbrt(s)

	return
		L: 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
		a: 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
		b: 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_

# Helper: Oklab to Linear RGB
def oklabToLinearRgb L, a, b
	const l_ = L + 0.3963377774 * a + 0.2158037573 * b
	const m_ = L - 0.1055613458 * a - 0.0638541728 * b
	const s_ = L - 0.0894841775 * a - 1.2914855480 * b

	const l = l_ ** 3
	const m = m_ ** 3
	const s = s_ ** 3

	return
		r: 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
		g: -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
		b: -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

# --------------------------------------------------
# Function to mix two hex colors in Oklab space
# with a given percent for the first color
# --------------------------------------------------
export def mix hex1, percent, hex2

	# Convert hex to RGB
	const rgb1 = hexToRgb(hex1)
	const rgb2 = hexToRgb(hex2)

	# Convert RGB to linear RGB
	const lin1 =
		r: srgbToLinear(rgb1.r)
		g: srgbToLinear(rgb1.g)
		b: srgbToLinear(rgb1.b)
	const lin2 =
		r: srgbToLinear(rgb2.r)
		g: srgbToLinear(rgb2.g)
		b: srgbToLinear(rgb2.b)

	# Convert linear RGB to Oklab
	const lab1 = linearRgbToOklab(lin1.r, lin1.g, lin1.b)
	const lab2 = linearRgbToOklab(lin2.r, lin2.g, lin2.b)

	# Interpolate in Oklab space
	const t = percent / 100
	const mixedLab = 
		L: lab1.L * t + lab2.L * (1 - t)
		a: lab1.a * t + lab2.a * (1 - t)
		b: lab1.b * t + lab2.b * (1 - t)

	# Convert Oklab back to linear RGB
	const linMixed = oklabToLinearRgb(mixedLab.L, mixedLab.a, mixedLab.b)

	# Convert linear RGB to sRGB and clamp
	const srgbMixed =
		r: Math.round(Math.min(Math.max(linearToSrgb(linMixed.r), 0), 1) * 255)
		g: Math.round(Math.min(Math.max(linearToSrgb(linMixed.g), 0), 1) * 255)
		b: Math.round(Math.min(Math.max(linearToSrgb(linMixed.b), 0), 1) * 255)

	# Convert to hex
	return rgbToHex(srgbMixed.r, srgbMixed.g, srgbMixed.b)


# --------------------------------------------------
# Main function to create a color palette
# --------------------------------------------------
export def pallete name\string, lightest\string, peak\string, darkest\string
	const colors = []

	for i in [0 .. 9]
		colors.push mix(peak, i * 10, lightest)
	colors.push peak
	for i in [1 .. 10]
		colors.push mix(peak, 100 - i * 10, darkest)
	
	if name
		for i in [0 .. 19]
			document.documentElement.style.setProperty("--{name}{i}", "light-dark({colors[i]},{colors[19 - i]})")
	
	return colors


