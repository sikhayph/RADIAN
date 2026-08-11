import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      // ── RADIAN color tokens — mirrors app_theme.dart ──────────────────────
      colors: {
        // Obsidian (default dark)
        obsidian: {
          bg:        '#0D1117',
          surface:   '#161B22',
          border:    '#30363D',
          primary:   '#58A6FF',
          secondary: '#3DCFB8',
          arm1:      '#F78166',
          arm2:      '#7EE787',
          resultant: '#E3B341',
          text:      '#E6EDF3',
          muted:     '#8B949E',
        },
        // Chalk (light / classroom)
        chalk: {
          bg:        '#FAFAFA',
          surface:   '#F0F2F5',
          border:    '#D0D7DE',
          primary:   '#0969DA',
          secondary: '#1A7F64',
          arm1:      '#CF222E',
          arm2:      '#116329',
          resultant: '#9A6700',
          text:      '#1F2328',
          muted:     '#656D76',
        },
        // Sikhay (branded dark)
        sikhay: {
          bg:        '#0A0A0A',
          surface:   '#141414',
          border:    '#2A2A2A',
          primary:   '#FFFFFF',
          secondary: '#AAAAAA',
          arm1:      '#FFFFFF',
          arm2:      '#AAAAAA',
          resultant: '#E0E0E0',
          text:      '#FFFFFF',
          muted:     '#888888',
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      // ── Premium easing curve — used in place of Tailwind's linear/ease-in-out defaults ──
      transitionTimingFunction: {
        DEFAULT: 'cubic-bezier(0.4, 0, 0.2, 1)',
        premium: 'cubic-bezier(0.4, 0, 0.2, 1)',
      },
    },
  },
  plugins: [],
}

export default config
