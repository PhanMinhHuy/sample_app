import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "bootstrap"
require("jquery")
import I18n from "i18n-js"

window.I18n = I18n
Rails.start()
Turbolinks.start()
ActiveStorage.start()
