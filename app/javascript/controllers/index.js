import { application } from "./application"

// Import controllers
import UsernameValidationController from "./username_validation_controller"

// Register controllers
application.register("username-validation", UsernameValidationController)
