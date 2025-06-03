import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

// Initialize Stimulus application
const application = Application.start()

// Register controllers from controllers directory
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))

// Or if using the default controllers loading approach in Rails 7:
import "controllers"
