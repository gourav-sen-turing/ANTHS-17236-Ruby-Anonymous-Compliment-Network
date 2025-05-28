/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.{html,html.erb,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
