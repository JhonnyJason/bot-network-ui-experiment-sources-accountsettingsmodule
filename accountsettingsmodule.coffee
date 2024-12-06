############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("accountsettingsmodule")
#endregion

############################################################
import { ThingyCryptoNode } from "thingy-crypto-node"

############################################################
#region modulesFromEnvironment

import * as state from "./statemodule.js"
import * as utl from "./utilsmodule.js"
import * as qrDisplay from "./qrdisplaymodule.js"
import * as qrReader from "./qrreadermodule.js" 
import * as triggers from "./navtriggers.js"

############################################################
import * as keygeneration from "./keygeneration.js"
import * as keyimport from "./keyimport.js"
import * as keyexport from "./keyexport.js"

############################################################
import { cryptoContext } from "./configmodule.js"

#endregion

############################################################
idContent = null
currentCryptoNode = null
currentKeyObj = null

############################################################
export initialize = ->
    log "initialize"
    idDisplay.addEventListener("click", idDisplayClicked)
    idQrButton.addEventListener("click", idQrButtonClicked)
    
    idContent = idDisplay.getElementsByClassName("display-frame-content")[0]

    generateKeyButton.addEventListener("click", generateKeyButtonClicked)
    importKeyButton.addEventListener("click", importKeyButtonClicked)
    exportKeyButton.addEventListener("click", exportKeyButtonClicked)
    deleteKeyButton.addEventListener("click", deleteKeyButtonClicked)

    keygeneration.initialize()
    keyimport.initialize()    
    keyexport.initialize()

    readKeyObject()
    createCurrentCryptoNode()
    updateDisplay()
    return

############################################################
#region internalFunctions
createCurrentCryptoNode = ->
    log "createCurrentCryptoNode"
    if !currentKeyObj? then return currentCryptoNode = null

    try
        options = {
            secretKeyHex: currentKeyObj.secretKeyHex
            publicKeyHex: currentKeyObj.publicKeyHex
            context: cryptoContext
        }
        currentCryptoNode = new ThingyCryptoNode(options)
    catch err then log err
    return

############################################################
onServerURLChanged = ->
    log "onServerURLChanged"
    serverURL = state.load("secretManagerURL")
    secretManagerClient.updateServerURL(serverURL)
    return

############################################################
readKeyObject = ->
    log "readKeyObject"
    protection = state.load("protection")
    accountId = state.load("accountIdHex")

    log "accountId is "+accountId

    if !utl.isValidKey(accountId) then return

    publicKeyHex = accountId
    secretKeyHex = ""
    keyTraceHex = ""
    keySaltHex = ""

    switch protection
        when "none" then secretKeyHex = state.load("secretKeyHex")
        when "qr", "phrase"
            keyTraceHex = state.load("keyTraceHex")
            keySaltHex = state.load("keySaltHex")

    currentKeyObj = { secretKeyHex, publicKeyHex, protection, keyTraceHex, keySaltHex }
    return

############################################################
updateDisplay = ->
    log "updateDisplay"
    if currentKeyObj? and currentKeyObj.publicKeyHex? and currentCryptoNode?
        idContent.textContent = utl.add0x(currentKeyObj.publicKeyHex)
        document.body.classList.remove("no-key")
    else 
        idContent.textContent = ""
        document.body.classList.add("no-key")
    return

############################################################
#region eventListeners
idDisplayClicked = ->
    log "idDisplayClicked"
    utl.copyToClipboard(idContent.textContent)
    return

idQrButtonClicked = ->
    log "idDisplayClicked"
    qrDisplay.displayCode(idContent.textContent)
    return


############################################################
generateKeyButtonClicked = ->
    log "generateKeyButtonClicked"
    triggers.keyGeneration()
    return

importKeyButtonClicked = ->
    log "importKeyButtonClicked"
    triggers.keyImport()
    return

exportKeyButtonClicked = ->
    log "exportKeyButtonClicked"
    triggers.keyExport()
    return

deleteKeyButtonClicked = ->
    log "deleteKeyButtonClicked"
    triggers.deleteKey()
    return

############################################################
addKeyButtonClicked = ->
    log "addKeyButtonClicked"
    try
        serverURL = state.load("secretManagerURL")
        currentClient = createClient({serverURL})
        await currentClient.keysReady
        log "publicKeyHex: #{currentClient.publicKeyHex}"
        log "secretKeyHex: #{currentClient.secretKeyHex}"
        
        state.save("secretKeyHex", currentClient.secretKeyHex)
        state.save("publicKeyHex", currentClient.publicKeyHex)
        state.save("accountId", currentClient.publicKeyHex)
    catch err
        log "Error when trying to create a new client on #{serverURL}\n#{err.message}"
    return


############################################################
importKeyInputChanged = ->
    log "importKeyInputChanged"
    validKey = utl.isValidKey(importKeyInput.value)
    log "input is valid key: "+validKey
    if validKey then accountsettings.classList.add("importing")
    else accountsettings.classList.remove("importing")
    return

acceptKeyButtonClicked = ->
    log "acceptKeyButtonClicked"
    key = utl.strip0x(importKeyInput.value)
    return unless utl.isValidKey(key)
    serverURL = state.load("secretManagerURL")
    currentClient = await createClient(key, null, serverURL)
    state.save("secretKeyHex", currentClient.secretKeyHex)
    state.save("publicKeyHex", currentClient.publicKeyHex)
    state.save("accountId", currentClient.publicKeyHex)
    importKeyInput.value = ""
    importKeyInputChanged()
    return

############################################################
qrScanImportClicked = ->
    log "qrScanImportClicked"
    try
        key = await qrReader.read()
        importKeyInput.value = key
        importKeyInputChanged()
    catch err then log err
    return

floatingImportClicked = ->
    log "floatingImportClicked"
    ##TODO implement
    return

signatureImportClicked = ->
    log "signatureImportClicked"
    ##TODO implement
    return

############################################################
copyExportClicked = ->
    log "copyExportClicked"
    key = state.load("secretKeyHex")
    utl.copyToClipboard(key)
    return

qrExportClicked = ->
    log "qrExportClicked"
    key = state.load("secretKeyHex")
    qrDisplay.displayCode(key)
    return

floatingExportClicked = ->
    log "floatingExportClicked"
    return

signatureExportClicked = ->
    log "signatureExportClicked"
    return

#endregion

#endregion

############################################################
storeKeyObject = ->
    log "storeKeyObject"

    state.save("accountIdHex", currentKeyObj.publicKeyHex, false)
    state.save("protection", currentKeyObj.protection, false)
    state.save("keyTraceHex", currentKeyObj.keyTraceHex, false)
    state.save("keySaltHex", currentKeyObj.keySaltHex, false)

    if currentKeyObj.protection == "none"
        state.save("secretKeyHex", currentKeyObj.secretKeyHex, false)
    else
        state.remove("secretKeyHex")

    # state.saveAll()
    return

############################################################
useUnprotectedKey = (fullKeyHandle) ->
    log "useUnprotectedKey"

    secretKeyHex = fullKeyHandle.secretKeyHex
    publicKeyHex = fullKeyHandle.publicKeyHex
    protection = fullKeyHandle.protection
    keyTraceHex = ""
    keySaltHex = ""

    currentKeyObj = { secretKeyHex, publicKeyHex, protection, keyTraceHex, keySaltHex }
    storeKeyObject()

    createCurrentCryptoNode()
    updateDisplay()
    return

useProtectedKey = (fullKeyHandle) ->
    log "useProtectedKey"

    secretKeyHex = fullKeyHandle.secretKeyHex
    publicKeyHex = fullKeyHandle.publicKeyHex
    protection = fullKeyHandle.protection
    keyTraceHex = fullKeyHandle.keyTraceHex
    keySaltHex = fullKeyHandle.keySaltHex

    currentKeyObj = { secretKeyHex, publicKeyHex, protection, keyTraceHex, keySaltHex }
    storeKeyObject()

    createCurrentCryptoNode()
    updateDisplay()
    return

############################################################
export getCryptoNode = -> currentCryptoNode
export hasKey = -> currentCryptoNode?

export deleteAccount = ->
    log "deleteAccount"
    currentCryptoNode = null
    currentKeyObj = null
    
    state.remove("secretKeyHex")
    state.remove("accountIdHex")
    state.remove("protection")
    state.remove("keyTraceHex")
    state.remove("keySaltHex")
    
    updateDisplay()
    return

export useNewKey = (fullKeyHandle) ->
    log "useNewKey"
    if fullKeyHandle.protection == "none" then useUnprotectedKey(fullKeyHandle)
    else useProtectedKey(fullKeyHandle)
    return

############################################################
#region UI Functions
export setToKeyGeneration = ->
    log "setToKeyGeneration"
    accountsettings.className = "generate-key"
    return

export setToKeyImport = ->
    log "setToKeyImport"
    accountsettings.className = "import-key"
    return

export setToKeyExport = ->
    log "setToKeyExport"
    accountsettings.className = "export-key"
    return

export setOff = ->
    log "setOff"
    accountsettings.className = ""
    return
    
#endregion


#92e102b2b2ef0d5b498fae3d7a9bbc94fc6ddc9544159b3803a6f4d239d76d62