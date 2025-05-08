
# Color Modes for Imba

A lightweight Imba module for managing color modes and performing perceptual color mixing, to make implementing dark and light modes much simpler.

## 🌗 Features

* **Color Mode Management**: Get and set color mode (`light`, `dark`, or `system`).
* **Persistence**: Stores user choice in local storage across sessions.
* **Auto-Detection**: `system` preset follows OS/browser preference via `window.matchMedia`.
* **Color Mixing**: `mix(color1, percent, color2)` returns an interpolated color in hex (Oklab-based).
* **Color Palette Generation**: `palette(name, lightest, color, darkest)` generates a smooth 21-color gradient from lightest to darkest, centered on the `color`.
* **Switcher Components**: `<ColorModeSwitcher>` and `<ColorModeSwitcherSimple>` to toggle between light and dark modes.

## 🛠 Installation

Add the module to your Imba project:

```bash
# if you are using NodeJS
npm install imba-color-modes 
# or if you are using Bun
bun add imba-color-modes
```

## 📦 Basic Usage

```imba
import {ColorModes} from 'imba-color-modes'

# Initialize
const modes = new ColorModes!

# Read current settings
console.log modes.preset   # 'light', 'dark', or 'system'
console.log modes.active   # resolved to 'light' or 'dark'

# Boolean getters
# If one is true - two others are false.
# This means that if the mode is 'system'
# dark and light will result to false. In other words
# boolean getters are not resolved the same as 'active'
console.log modes.light    # false
console.log modes.dark     # false
console.log modes.auto     # true

# Change mode
modes.preset = 'dark'
# or via booleans
modes.light = true
# or directly setting active
modes.active = 'system'

# Toggle between light/dark
modes.toggle!
```

## 🧠 How It Works

* **`ColorMode.preset`** holds `'light'|'dark'|'system'` (persisted).
* **`ColorMode.active`** resolves to `'light'` or `'dark'` (system fallback if needed).
* **Boolean properties**: `.light`, `.dark`, `.auto` for easy toggling.
* **`toggle()`** switches between `light` and `dark` presets.

## 🎨 Palette Functions

This library contains additional functions to simplify the work with themes:
* **`mix(color1, parecent, color2)`** converts hex inputs to Oklab, interpolates, and returns hex for perceptually uniform transitions with (percent)% of color1 and (100 - percent)% of color2.
* **`palette(name, [array of shades for light], [array of shades for dark])`** generates CSS variables based color themes independent for light and dark modes.

```imba
import {mix, pallete} from 'imba-color-modes'

# Color mixing
const blended = mix('#ff0000', 20, '#0000ff')  # mixes 20% of red with 80% of blue in Oklab space
console.log blended  # '#4441db'

# Generate light and dark palettes with the same name 'base' of 10 smoothly transitioning colors
palette('base', ['#FFFFFF', 8, '#FF0000'], ['#000000', 8, '#FF0000'])

# using colors of the pallete in css
css .block bgc:$base2 bdc:$base6
```

Pallete function receives two arrays that define the colors for light and dark modes (which should contain the equal amount of colors). It can be just colors or colors with a number in between - in this case the function will generate the number of shades between this two colors. For example, the light (or dark) pallete can be defined like this: `['#FFFFFF', '#EEEEEE', 8, '#000000']`. This pallete will add white, then gray, then 8 shades between gray and black and at last black - generating as a result 10 CSS variables: from $name0 to $name9.

Pallete function allows to create custom color palletes that can be used almost the same as built-in color names in Imba (the only difference is that these custom colors can be used only in CSS and their names should start with leading $ sign).

But more importantly it creates TWO independent palletes for light and dark modes accessed with the same name space. For example, in the example above variable `$base2` will have different values in light and dark modes. In light mode it will be two steps from white to red, while in dark it will be two steps from black to red.

This approach allows, to create let's say a dark theme for an application using CSS variables, and then just tune the color pallete for light theme without making many small changes all over the code to adjust each tag style. Such concentrating of all the tuning in one place makes it much more simple for developers to get second theme almost automatically and should be enough in majority of cases.

**Note:** You can use mixed colors to generate palletes:
`pallete 'accent', ['#FFFFFF', 8, color], [mix(color,50,'#000000'), 8, color]`


## 🔄 Switcher Components

This library contains two plug and play components, that can be easily used in your Imba application to switch between color modes.

**ColorModeSwitcher** shows three icons a user can click: light, dark, system. 
**ColorModeSwitcherSimple** shows only one icon to toggle between light/dark modes.

To make these components work an instance of the ColorModes class should be passed in the `enginge` attribute. 

```imba
import {ColorModes} from 'imba-color-mode'
import {ColorModeSwitcher, ColorModeSwitcherSimple} from 'imba-color-mode/components'

const modes = new ColorModes!
<ColorModeSwitcher engine=modes>
<ColorModeSwitcherSimple engine=modes>
```

### Component Styling

Both of the color mode switching components are built in a way to make their adjusment as simple as possible through CSS classes. These classes can be altered via Imba inheritance mechanics.

Here how built-in CSS classes look like in components
```imba
# ColorModeSwitcher
.container 
	gap:8px rd:8px p:4px 
	bgc:light-dark(#000000/10, #FFFFFF/20)
.button 
	cursor:pointer 
	w:36px h:36px p:8px rd:6px
	bgc@hover:light-dark(#000000/10, #FFFFFF/20) 
	fill:light-dark(#000000/40, #FFFFFF/50)
.button-active 
	cursor:default 
	bgc:light-dark(#000000/10, #FFFFFF/20) 
	fill:light-dark(#000000, #FFFFFF)
	
# ColorModeSwitcherSimple
.button 
	cursor:pointer
	gap:8px rd:8px p:8px 
	bgc:light-dark(#000000/10, #FFFFFF/20) 
	bgc@hover:light-dark(#000000/20, #FFFFFF/30)
.icon 
	h:20px w:20px 
	fill:light-dark(#000000, #FFFFFF)
```

And here is example how to adjust the CSS properties of the components:
```imba
import {ColorModeSwitcher, ColorModeSwitcherSimple} from 'imba-color-mode/components'

tag ModeSwitcher < ColorModeSwitcher
	css
		.container gap:20px
		.button rd:50%
		.button-active bgc:yellow

tag ModeSwitcherSimple < ColorModeSwitcherSimple
	css
		.button rd:50%
		.icon h:40px w:40px fill:yellow

# Use this adjusted components as usual:
tag App
	<self>
		<ModeSwitcherSimple>

```
The icons can be passed as tags to component attributes:

```imba
tag SomeIcon
	<self>
		<svg viewBox="..." xmlns="http://www.w3.org/2000/svg">
			<path d="...">


<ColorModeSwitcher light=SomeIcon> # available icon attributes: light, dark, system
<ColorModeSwitcherSimple light=SomeIcon> # available icon attributes: light, dark
```

## 🧩 Moon, Sun and Monitor icons

You can also use the three SVG icons included in this package: Moon, Sun and Monitor.

```imba
import {MoonIcon, SunIcon, MonitorIcon} from 'imba-color-mode/components'

tag App
	<self>
		<MoonIcon>
			css w:20px h:20px fill:white stroke:red
```