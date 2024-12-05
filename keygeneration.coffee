############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("keygeneration")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"
import * as utl from "./utilsmodule.js"

############################################################
#region DOM cache
regenerationButton = document.getElementById("keygeneration-regeneration-button")
useButton = document.getElementById("keygeneration-use-button")
cancelButton = document.getElementById("keygeneration-cancel-button")

keyIdDisplay = document.getElementById("keygeneration-key-id-display")
protectedIndicator = document.getElementById("keygeneration-protected-indicator")
#endregion


############################################################
currentKeyObj = null

############################################################
export initialize = ->
    log "initialize"

    regenerationButton.addEventListener("click", regenerationButtonClicked)

    useButton.addEventListener("click", useButtonClicked)
    cancelButton.addEventListener("click", cancelButtonClicked)

    generateNewRawKey()
    return

############################################################
generateNewRawKey = ->
    log "generateNewRawKey"
    currentKeyObj = await secUtl.createKeyPairHex()
    keyIdDisplay.textContent = utl.add0x(currentKeyObj.publicKeyHex)
    protectedIndicator.className = ""
    return

############################################################
useButtonClicked = ->
    log "useButtonClicked"
    
    return

cancelButtonClicked = ->
    log "cancelButtonClicked"
    accountsettings.classList.remove("generate-key")
    return

regenerationButtonClicked = ->
    log "regenerationButtonClicked"
    generateNewRawKey()
    return
