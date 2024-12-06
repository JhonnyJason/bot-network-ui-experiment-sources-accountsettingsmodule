############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("keyexport")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"
import * as utl from "./utilsmodule.js"

############################################################
#region DOM cache
useButton = document.getElementById("keyexport-use-button")
cancelButton = document.getElementById("keyexport-cancel-button")

keyIdDisplay = document.getElementById("keyexport-key-id-display")
#endregion


############################################################
currentKeyObj = null

############################################################
export initialize = ->
    log "initialize"
    useButton.addEventListener("click", useButtonClicked)
    cancelButton.addEventListener("click", cancelButtonClicked)
    return


############################################################
useButtonClicked = ->
    log "useButtonClicked"
    
    return

cancelButtonClicked = ->
    log "cancelButtonClicked"
    accountsettings.classList.remove("export-key")
    return