pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers", preload: true
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@3.7.1/dist/chart.esm.js"
# Any other required JavaScript packages or libraries

# If using stimulus-webpack-helpers
pin "@hotwired/stimulus-webpack-helpers", to: "stimulus-webpack-helpers.js", preload: true
