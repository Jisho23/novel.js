
### UI SCRIPTS ###

class UI

  # Create instance
  instance = null
  constructor: ->
    if instance
      return instance
    else
      instance = this

  @init: ->
    n = document.getElementsByTagName('novel')[0];
    if not n
      n = document.getElementById('novel-area')
    if n
      d = document.createElement('div');
      d.id = "novel-area"
      d.innerHTML = '<div id="novel-style-area">
        <div id="novel-notification-wrapper">
          <div id="novel-save-notification" class="novel-notification">
            <p>' + LanguageManager.getUIString('saveText') + '</p>
            <p><textarea name="save-text" readonly></textarea></p>
            <p><button type="button" onclick="UI.closeSaveNotification()">' + LanguageManager.getUIString('closeButton') + '</button><button type="button" id="novel-copy-button">' + LanguageManager.getUIString('copyButton') + '</button></p>
          </div>
          <div id="novel-load-notification" class="novel-notification">
            <p>' + LanguageManager.getUIString('loadText') + '</p>
            <p><textarea name="load-text"></textarea></p>
            <p><button type="button" onclick="UI.closeLoadNotification(false)">' + LanguageManager.getUIString('closeButton') + '</button><button type="button" onclick="UI.closeLoadNotification(true)">' + LanguageManager.getUIString('loadButton') + '</button></p>
          </div>
        </div>
        <div id="novel-text-area">
          <div id="novel-text"></div>
          <button type="button" id="novel-skip-button" onclick="TextPrinter.complete()">' + LanguageManager.getUIString('skipButton') + '</button>
          <button type="button" id="novel-continue-button" onclick="TextPrinter.unpause()">' + LanguageManager.getUIString('continueButton') + '</button>
        </div>
        <div id="novel-choices-area">
          <ul id="novel-choice-list"></ul>
        </div>
        <div id="novel-inventory-area">
          <h5>' + LanguageManager.getUIString('inventoryTitle') + '</h5>
          <ul id="novel-inventory"></ul>
        </div>
        <div id="novel-hidden-inventory-area">
          <h5>' + LanguageManager.getUIString('hiddenInventoryTitle') + '</h5>
          <ul id="novel-hidden-inventory"></ul>
        </div>
        <div id="novel-save-area">
          <button type="button" id="novel-save-button" onclick="NovelManager.saveData()">' + LanguageManager.getUIString('saveButton') + '</button>
          <button type="button" id="novel-load-button" onclick="UI.showLoadNotification()">' + LanguageManager.getUIString('loadButton') + '</button>
        </div>
      </div>';
      n.parentNode.insertBefore(d, n);
      n.parentNode.removeChild(n);

  @updateStyle: (style) ->
    e = document.getElementById("novel-style-area")
    if style is undefined
      style = ""
    e.setAttribute( 'class', style );

  @disableSkipButton: ->
    if document.querySelector("#novel-skip-button") isnt null
      document.querySelector("#novel-skip-button").disabled = true;

  @enableSkipButton: ->
    if document.querySelector("#novel-skip-button") isnt null
      document.querySelector("#novel-skip-button").disabled = true;

  @showSkipButton: (show) ->
    e = document.getElementById("novel-skip-button")
    if show && novelData.novel.settings.showSkipButton
      e.style.display = "inline"
    else
      e.style.display = "none"

  @showChoicesArea: (show) ->
    e = document.getElementById("novel-choices-area")
    if show
      e.style.display = "inline"
    else
      e.style.display = "none"

  @showInventoryArea: (show) ->
    e = document.getElementById("novel-inventory-area")
    if show
      e.style.display = "inline"
    else
      e.style.display = "none"

  @showHiddenInventoryArea: () ->
    e = document.getElementById("novel-hidden-inventory-area")
    if novelData.novel.settings.debugMode
      e.style.display = "inline"
    else
      e.style.display = "none"

  @showSaveButtons: (show) ->
    e = document.getElementById("novel-save-area")
    if show
      e.style.display = "inline"
    else
      e.style.display = "none"

  @showContinueButton: (show) ->
    if document.querySelector("#novel-continue-button") isnt null
      if not show
        document.querySelector("#novel-continue-button").style.display = 'none'
      else
        document.querySelector("#novel-continue-button").style.display = 'inline'

  @updateText: (text) ->
    e = document.getElementById("novel-text")
    e.innerHTML = text

  # Show the save notification window, and update its text
  @showSaveNotification: (text) ->
    e = document.getElementById("novel-save-notification")
    textArea = e.querySelectorAll("textarea")
    textArea[0].value = text
    e.style.display = 'block';

  # Close the save notification window
  @closeSaveNotification: ->
    e = document.getElementById("novel-save-notification")
    e.style.display = 'none';

  # Show the load notification window
  @showLoadNotification: ->
    if novelData.novel.settings.saveMode is "text"
      e = document.getElementById("novel-load-notification")
      e.style.display = 'block';
    else
      NovelManager.loadGame()

  # Close the load notification - if load, then load a save. ChangeScene defines whether the scene should be updated or not.
  @closeLoadNotification: (load, changeScene) ->
    e = document.getElementById("novel-load-notification")
    if load
      textArea = e.querySelectorAll("textarea")
      NovelManager.loadData(textArea[0].value,changeScene)
      textArea[0].value = ""
    e.style.display = 'none'

  # Update the values of the input fields
  @updateInputs: (needForUpdate) ->
    inputs = document.getElementById("novel-area").querySelectorAll("input")
    for i in inputs
      for a in novelData.novel.inventories[novelData.novel.currentInventory]
        if a.name is i.className.substring(6,i.className.length)
          a.value = Util.stripHTML(i.value)
          if needForUpdate
            SceneManager.updateScene(novelData.novel.currentScene,true)

  # Reset all choices
  @resetChoices: () ->
    choiceArea = document.getElementById("novel-choice-list")
    while choiceArea.firstChild
      choiceArea.removeChild(choiceArea.firstChild)

  # Reset the inventories
  @resetInventories: () ->
    inventoryArea = document.getElementById("novel-inventory")
    while inventoryArea.firstChild
      inventoryArea.removeChild(inventoryArea.firstChild)
    inventoryArea = document.getElementById("novel-hidden-inventory")
    while inventoryArea.firstChild
      inventoryArea.removeChild(inventoryArea.firstChild)

  # Update the choices
  @updateChoices: () ->
    @resetChoices()
    choiceArea = document.getElementById("novel-choice-list")
    i = 0
    for i in [0 ... novelData.novel.currentScene.choices.length]
      choice = novelData.novel.currentScene.choices[i]
      if choice.text
        choice.parsedText = Parser.parseText(LanguageManager.getCorrectLanguageString(choice.text))
        if SceneManager.requirementsFilled(choice)
          li = document.createElement("li")
          li.innerHTML = '<a href="#"; onclick="SceneManager.selectChoiceById(' + i + ')">' + choice.parsedText + '</a>'
          choiceArea.appendChild(li)
        else if choice.alwaysShow || novelData.novel.settings.alwaysShowDisabledChoices
          li = document.createElement("li")
          li.innerHTML = choice.parsedText
          choiceArea.appendChild(li)

  # Update the inventory items
  @updateInventories: () ->
    @resetInventories()
    inventoryArea = document.getElementById("novel-inventory")
    hiddenInventoryArea = document.getElementById("novel-hidden-inventory")
    for item in novelData.novel.inventories[novelData.novel.currentInventory]
      targetInventory = hiddenInventoryArea
      if not item.hidden or item.hidden is undefined
        targetInventory = inventoryArea
      if item.value > 0 or isNaN item.value
        li = document.createElement("li")
        li.class = "novel-inventory-item"
        innerHTML = LanguageManager.getItemAttribute(item,'displayName') + ' - ' + item.value
        innerHTML = innerHTML + '<ul class="novel-inventory-item-info">'
        if item.description
          innerHTML = innerHTML + '<li class="novel-inventory-item-description">' + LanguageManager.getItemAttribute(item,'description') + '</li>'
        innerHTML = innerHTML + '</ul>'
        li.innerHTML = innerHTML
        targetInventory.appendChild(li)


# The button that can be used to copy the text from the save window.
copyButton = document.querySelector('#novel-copy-button')
if copyButton isnt null
  copyButton.addEventListener 'click', (event) ->
    copyTextarea = document.getElementById("novel-save-notification").querySelector("textarea")
    copyTextarea.select()
    try
      successful = document.execCommand('copy')
    catch err
      console.error "Copying to clipboard failed: "+err
