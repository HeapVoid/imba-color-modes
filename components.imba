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
def check engine
	console.log "ColorModeSwitcher: engine not set" if !engine 

export tag ColorModeSwitcher
	engine
	light = SunIcon
	dark = MoonIcon
	system = MonitorIcon

	def mount
		check(engine)

	css
		.container gap:8px rd:8px p:4px bgc:light-dark(#000000/10, #FFFFFF/20)
		.button w:36px h:36px p:8px rd:6px cursor:pointer bgc@hover:light-dark(#000000/10, #FFFFFF/20) fill:light-dark(#000000/40, #FFFFFF/50)
		.button-active bgc:light-dark(#000000/10, #FFFFFF/20) cursor:default fill:light-dark(#000000, #FFFFFF)

	<self> if engine
		<div.container [d:hflex]>
			<{light}.button [d:inline-flex jc:center] .button-active=engine.light @click=(engine.light = true)>
			<{dark}.button [d:inline-flex jc:center] .button-active=engine.dark @click=(engine.dark = true)>
			<{system}.button [d:inline-flex jc:center] .button-active=engine.auto @click=(engine.auto = true)>

export tag ColorModeSwitcherSimple
	engine
	light = SunIcon
	dark = MoonIcon

	def mount
		check(engine)

	css
		.button gap:8px rd:8px p:8px bgc:light-dark(#000000/10, #FFFFFF/20) bgc@hover:light-dark(#000000/20, #FFFFFF/30) cursor:pointer
		.icon h:20px w:20px fill:light-dark(#000000, #FFFFFF)

	<self> if engine
		<div.button [w:100% h:100% d:hflex] @click=engine.toggle!>
			if engine.active == 'dark'
				<{light}.icon [d:inline-flex jc:center]>
			else
				<{dark}.icon [d:inline-flex jc:center]>