import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// carrega todos os arquivos .js em app/javascript/controllers (exceto application.js e index.js)
eagerLoadControllersFrom("controllers", application)
