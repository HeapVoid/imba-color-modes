export class ColorModesState

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
# Icons
# --------------------------------------------------
export tag MoonIcon
	<self>
		<svg viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
			<path d="M235.54,150.21a104.84,104.84,0,0,1-37,52.91A104,104,0,0,1,32,120,103.09,103.09,0,0,1,52.88,57.48a104.84,104.84,0,0,1,52.91-37,8,8,0,0,1,10,10,88.08,88.08,0,0,0,109.8,109.8,8,8,0,0,1,10,10Z">

export tag SunIcon
	<self>
		<svg viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
			<path d="M120,40V16a8,8,0,0,1,16,0V40a8,8,0,0,1-16,0Zm8,24a64,64,0,1,0,64,64A64.07,64.07,0,0,0,128,64ZM58.34,69.66A8,8,0,0,0,69.66,58.34l-16-16A8,8,0,0,0,42.34,53.66Zm0,116.68-16,16a8,8,0,0,0,11.32,11.32l16-16a8,8,0,0,0-11.32-11.32ZM192,72a8,8,0,0,0,5.66-2.34l16-16a8,8,0,0,0-11.32-11.32l-16,16A8,8,0,0,0,192,72Zm5.66,114.34a8,8,0,0,0-11.32,11.32l16,16a8,8,0,0,0,11.32-11.32ZM48,128a8,8,0,0,0-8-8H16a8,8,0,0,0,0,16H40A8,8,0,0,0,48,128Zm80,80a8,8,0,0,0-8,8v24a8,8,0,0,0,16,0V216A8,8,0,0,0,128,208Zm112-88H216a8,8,0,0,0,0,16h24a8,8,0,0,0,0-16Z">

export tag MonitorIcon
	<self>
		<svg viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
			<path d="M232,64V176a24,24,0,0,1-24,24H48a24,24,0,0,1-24-24V64A24,24,0,0,1,48,40H208A24,24,0,0,1,232,64ZM160,216H96a8,8,0,0,0,0,16h64a8,8,0,0,0,0-16Z">

# --------------------------------------------------
# Components to switch color modes
# --------------------------------------------------

# Helper functon to reduce overall library size
def check state
	console.log "ColorModeSwitcher: the state is not set" if !state

export tag ColorModeSwitcher
	state
	light = SunIcon
	dark = MoonIcon
	system = MonitorIcon

	def mount
		check(state)

	css
		.container gap:8px rd:8px p:4px bgc:light-dark(#000000/10, #FFFFFF/20)  w:100% > max-content
		.button w:36px h:36px p:8px rd:6px cursor:pointer bgc@hover:light-dark(#000000/10, #FFFFFF/20) fill:light-dark(#000000/40, #FFFFFF/50)
		.button-active bgc:light-dark(#000000/10, #FFFFFF/20) cursor:default fill:light-dark(#000000, #FFFFFF)

	<self> if state
		<div.container [d:hflex]>
			<{light}.button [d:inline-flex jc:center] .button-active=state.light @click=(state.light = true)>
			<{dark}.button [d:inline-flex jc:center] .button-active=state.dark @click=(state.dark = true)>
			<{system}.button [d:inline-flex jc:center] .button-active=state.auto @click=(state.auto = true)>

export tag ColorModeSwitcherSimple
	state
	light = SunIcon
	dark = MoonIcon

	def mount
		check(state)

	css
		.button gap:8px rd:8px p:8px bgc:light-dark(#000000/10, #FFFFFF/20) bgc@hover:light-dark(#000000/20, #FFFFFF/30) cursor:pointer
		.icon h:20px w:20px fill:light-dark(#000000, #FFFFFF)

	<self> if state
		<div.button [w:100% h:100% d:hflex] @click=state.toggle!>
			if state.active == 'dark'
				<{light}.icon [d:inline-flex jc:center]>
			else
				<{dark}.icon [d:inline-flex jc:center]>

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
const pallet_err = 
	'''Pallete definition is wrong. Please check that:
		- pallete starts and ends with the color (as a string)
		- pallete contains only numbers or colors (as string)
		- pallete contains at least one color
		- count of colors in dark and light palletes must be equal'''

export def pallete name\string, light = [], dark = []
	
	if !light or !light.length or !dark or !dark.length
		console.log pallet_err
		return
	
	if !(light[0] isa 'string') or !(light[-1] isa 'string') or !(dark[0] isa 'string') or !(dark[-1] isa 'string')
		console.log pallet_err

	let lights = []
	let darks = []

	for i in [0 ... light.length]
		if light[i] isa 'string'
			lights.push light[i]
		elif light[i] isa 'number' 
			for j in [1 .. light[i]]
				lights.push mix(light[i + 1], j * 100 / (light[i] + 1), light[i - 1])
		else 
			console.log pallet_err
			return

	for i in [0 ... dark.length]
		if dark[i] isa 'string'
			darks.push dark[i]
		elif dark[i] isa 'number' 
			for j in [1 .. dark[i]]
				darks.push mix(dark[i + 1], j * 100 / (dark[i] + 1), dark[i - 1])
		else 
			console.log pallet_err
			return

	if lights.length != darks.length
		console.log pallet_err
		return

	for i in [0 ... lights.length]
		document.documentElement.style.setProperty("--{name}{i}", "light-dark({lights[i]},{darks[i]})")