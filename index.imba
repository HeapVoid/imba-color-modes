import mix from './mix.imba'

global css
	@root
		color-scheme: light dark

export class ColorModes
	def constructor
		preset = imba.locals._color_mode

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
		return preset == 'system' ? system : imba.locals._color_mode

	set active value\string
		preset = value

	get system
		window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
	
	get preset
		return imba.locals._color_mode in ['light', 'dark', 'system'] ? imba.locals._color_mode : 'system'

	set preset value\string
		value = value in ['light', 'dark', 'system'] ? value : 'system'
		if value == 'system'
			delete imba.locals._color_mode
		else
			imba.locals._color_mode = value
		document.documentElement.style.colorScheme = active

	def toggle
		if active == 'dark'
			light = true
		else
			dark = true

# --------------------------------------------------
# Icons
# --------------------------------------------------
tag MoonIcon
	<self>
		<svg viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
			<path d="M235.54,150.21a104.84,104.84,0,0,1-37,52.91A104,104,0,0,1,32,120,103.09,103.09,0,0,1,52.88,57.48a104.84,104.84,0,0,1,52.91-37,8,8,0,0,1,10,10,88.08,88.08,0,0,0,109.8,109.8,8,8,0,0,1,10,10Z">

tag SunIcon
	<self>
		<svg viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
			<path d="M120,40V16a8,8,0,0,1,16,0V40a8,8,0,0,1-16,0Zm8,24a64,64,0,1,0,64,64A64.07,64.07,0,0,0,128,64ZM58.34,69.66A8,8,0,0,0,69.66,58.34l-16-16A8,8,0,0,0,42.34,53.66Zm0,116.68-16,16a8,8,0,0,0,11.32,11.32l16-16a8,8,0,0,0-11.32-11.32ZM192,72a8,8,0,0,0,5.66-2.34l16-16a8,8,0,0,0-11.32-11.32l-16,16A8,8,0,0,0,192,72Zm5.66,114.34a8,8,0,0,0-11.32,11.32l16,16a8,8,0,0,0,11.32-11.32ZM48,128a8,8,0,0,0-8-8H16a8,8,0,0,0,0,16H40A8,8,0,0,0,48,128Zm80,80a8,8,0,0,0-8,8v24a8,8,0,0,0,16,0V216A8,8,0,0,0,128,208Zm112-88H216a8,8,0,0,0,0,16h24a8,8,0,0,0,0-16Z">

tag MonitorIcon
	<self>
		<svg viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
			<path d="M232,64V176a24,24,0,0,1-24,24H48a24,24,0,0,1-24-24V64A24,24,0,0,1,48,40H208A24,24,0,0,1,232,64ZM160,216H96a8,8,0,0,0,0,16h64a8,8,0,0,0,0-16Z">

# --------------------------------------------------
# Components to switch color modes
# --------------------------------------------------
export tag ColorSchemeSwitcher
	engine
	light = SunIcon
	dark = MoonIcon
	system = MonitorIcon

	css
		$button-w: 36px
		$button-h: 36px
		$button-p: 8px
		$button-rd: 6px
		$button-bgc-passive: transparent
		$button-bgc-active: light-dark(#000000/10, #FFFFFF/20)
		$button-bgc-hover:light-dark(#000000/10, #FFFFFF/20)
		$icon-fill-passive: light-dark(#000000/40, #FFFFFF/50)
		$icon-fill-active: light-dark(#000000, #FFFFFF)

		.button w:$button-w h:$button-h p:$button-p d:inline-flex jc:center cursor:pointer fill:$icon-fill-passive bgc:$button-bgc-passive rd:$button-rd bgc@hover:$button-bgc-hover
		.active bgc:$button-bgc-active cursor:default fill:$icon-fill-active

	<self>
		css w:fit-content d:hflex gap:8px rd:8px p:4px bgc:light-dark(#000000/10, #FFFFFF/20)
		<{light}.button .active=engine.light @click=(engine.light = true)>
		<{dark}.button .active=engine.dark @click=(engine.dark = true)>
		<{system}.button .active=engine.auto @click=(engine.auto = true)>

export tag ColorModeSwitcherSimple
	engine
	light = SunIcon
	dark = MoonIcon

	css
		.button d:inline-flex jc:center

	<self @click=engine.toggle!>
		css w:fit-content h:36px d:hflex gap:8px rd:8px p:8px bgc:light-dark(#000000/10, #FFFFFF/20) bgc@hover:light-dark(#000000/20, #FFFFFF/30) fill:light-dark(#000000, #FFFFFF) cursor:pointer
		if engine.active == 'dark'
			<{light}.button>
		else
			<{dark}.button>

# --------------------------------------------------
# Palletes and color mixing
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

export * from './mix.imba'
