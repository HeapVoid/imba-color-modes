
# Color Modes for Imba

A lightweight Imba module for managing color modes and performing perceptual color mixing, to make implementing dark and light modes much simpler.

## 🌗 Features

* **Color Mode Management**: Get and set color mode (`light`, `dark`, or `system`).
* **Persistence**: Stores user choice in `imba.locals._color_mode` across sessions.
* **Auto-Detection**: `system` preset follows OS/browser preference via `window.matchMedia`.
* **Color Mixing**: `mix(color1, percent, color2)` returns an interpolated color in hex (Oklab-based).
* **Color Palette Generation**: `palette(name, lightest, color, darkest)` generates a smooth 21-color gradient from lightest to darkest, centered on the `color`.
* **Switcher Components**: `<ColorModeSwitcher>` and `<ColorModeSwitcherSimple>` to toggle between light and dark modes.

## 🛠 Installation

Add the module to your Imba project:

```bash
npm install imba-color-modes
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
# This means that if the mode is defined by the system 
# dark and light will result to false. In other words
# boolean getters are not resolved as 'active'
console.log modes.light    # false
console.log modes.dark     # false
console.log modes.auto     # true

# Change mode
modes.preset = 'dark'
# or via booleans
modes.light = true
# or
modes.active = 'system'

# Toggle between light/dark
modes.toggle!
```

## 🧠 How It Works

* **`ColorMode.preset`** holds `'light'|'dark'|'system'` (persisted).
* **`ColorMode.active`** resolves to `'light'` or `'dark'` (system fallback if needed).
* **Boolean properties**: `.light`, `.dark`, `.auto` for easy toggling.
* **`toggle()`** switches between `light` and `dark` presets.

## 🎨 Palette Function

This library contains additional functions to simplify the work with themes:
* **`mix(color1, parecent, color2)`** converts hex inputs to Oklab, interpolates, and returns hex for perceptually uniform transitions with (percent)% of color1 and (100 - percent)% of color2.
* **`palette(name, lightest, color, darkest)`** generates 21 colors smoothly varying from lightest to darkest around a given base color.

If the pallete is named (the 1st parameter is not empty string) each color in the generated pallete will be assigned to name-based CSS variables. 

```imba
import {mix, pallete} from 'imba-color-modes'

# Color mixing
const blended = mix('#ff0000', 20, '#0000ff')  # mixes 20% of red with 80% of blue in Oklab space
console.log blended  # '#4441db'

# Generate a palette named 'base' of 21 smoothly transitioning colors
const colors = palette('base', '#FFFFFF', color, '#000000')
console.log colors  # Array of 21 pallete hex colors
```

The `pallete` function generates 21 `light-dark` CSS variables: `$base0`, `$base1` ...  `$base19`, `$base20`
The idea is that in the light mode `$base0` resolves to the lightest color (`'#FFFFFF'` from the example), while in dark mode to darkest (`'#000000'`), and each next step is further from these starting colors. 

If we imagine the pallete as colors going from left to right from the lightest to darkest, in light mode numbering of CSS variables will go from left to right, while in dark mode it will be opposite - numbering will go from right to left. Howerver, in both dark and light modes `$base10` resolves to the main color (3rd parameter), since it is in the middle (10 steps away) from both sides.

This allows to use a single CSS variable and the system will automatically switch the color based on the active mode. For example, you can use these theme-aware variables in your styling pretty straightforward:

```imba
.block bgc: $base2
```

However, `$base2` will be drawn from either the light or dark palette depending on the current theme, two steps away from the starting color. In other words, in light mode it will be two steps darker than the lightest ('#FFFFFF'), while in dark mode it will be two steps lighter than the darkest ('#000000').

### Hints About Palletes

Opposite to wave frequency a color is not absolute, it is just a result of modeling reality in our minds. And we, humans, have a very weird color perception. It is anything but linear. Since first computers there were many attempts to unify somehow color spaces. And only recently appeared such color spaces as Oklab or Oklch (and they are not only weird but also not perfect).

As a result, building fully automatic coloring is almost impossible. However, opinionated approach implemented in this library makes it much more simple for developers.

Turned over pallete allows to work in the same shades pallete in dark and light modes. However, to make it work it should be adjusted: 
* Base color can be anything, so if it is too light, then each step from lighest to the center will be too small, while from center to darkest will be too big. So just turning over the pallete will not result in good visuals. So the base color should be adjusted properly, so it is really in the middle between laghtest and darkest.
* First steps in dark colors are not that perceptible as in the light. So better make darkest a little bit away from real black: `pallete 'base', '#FFFFFF', color, mix(color,25,'#000000')`
* Gray color looks very different with dark colors. So mix its darkest end with the main theme color: `pallete 'gray', '#FFFFFF', '#a8a8a8', mix(color,25,'#000000')`


## 🔄 Switcher Components

```imba
import {ColorModes} from 'imba-color-mode'
import {ColorModeSwitcher, ColorModeSwitcherSimple} from 'imba-color-mode/components'

const modes = new ColorModes!
<ColorModeSwitcher engine=modes>
<ColorModeSwitcherSimple engine=modes>
```
**ColorModeSwitcher** shows three icons a user can click: light, dark, system. 
**ColorModeSwitcherSimple** shows only one to toggle light/dark modes.

### Component Styling

Both `ColorModeSwitcher` and `ColorModeSwitcherSimple` are regular Imba tags, so you can style them using external CSS or Imba styles like any other component:

```imba
<ColorModeSwitcher>
    css p:8px rd:10px bgc:yellow
```
The icons can be passed as tags to component attributes:

```imba
tag SomeIcon
	<self>
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19.375 18.8909">
			<path d="...">


<ColorModeSwitcher light=SomeIcon> # dark, system
```

In addition `ColorModeSwitcher` supports a number of CSS variables for customization of deeper tags:

* `$button-w: 36px`
* `$button-h: 36px`
* `$button-p: 8px`
* `$button-rd: 6px`
* `$button-bgc-passive: transparent`
* `$button-bgc-active: light-dark(#000000/10, #FFFFFF/20)`
* `$button-bgc-hover:light-dark(#000000/10, #FFFFFF/20)`
* `$icon-fill-passive: light-dark(#000000/40, #FFFFFF/50)`
* `$icon-fill-active: light-dark(#000000, #FFFFFF)`

Example:

```imba
<ColorModeSwitcher>
    css $button-bgc-passive: #FEFEFE
```