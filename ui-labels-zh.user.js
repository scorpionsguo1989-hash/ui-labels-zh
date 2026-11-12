// ==UserScript==
// @name         UI Labels Zh
// @description  补译 Notion 界面中已核对的英文标签。
// @version      1.0.0
// @match        https://app.notion.com/*
// @grant        none
// @noframes
// ==/UserScript==

(() => {
  "use strict";

  if (location.origin !== "https://app.notion.com" || window !== window.top) return;

  const installation = Symbol.for("notion.zh.cn.interface");
  globalThis[installation]?.disconnect();

  const libraryTab = '[role="tablist"] [role="tab"]';
  const propertyButton = ':is(button, [role="button"])[aria-haspopup]';
  const control = [libraryTab, propertyButton].join(", ");
  const userContent = '[contenteditable]:not([contenteditable="false"]), .notion-page-content [data-block-id], textarea, input';
  const libraryLabels = new Map([
    ["Recents", "最近访问"],
    ["Favorites", "最爱"],
    ["Shared", "共享"],
    ["Private", "私人"],
  ]);
  const propertyLabels = new Map([["Add a property", "添加属性"]]);
  const labelAttributes = ["aria-label", "title"];

  function translateLabel(value, labels) {
    if (!value) return value;
    const label = value.trim();
    const chinese = labels.get(label);
    return chinese ? value.replace(label, chinese) : value;
  }

  function translateControl(element) {
    if (!element.isConnected || element.closest(userContent)) return;

    const inLibrary = /^\/library(?:\/|$)/.test(location.pathname);
    const isLibraryTab = element.matches(libraryTab);
    if (isLibraryTab && !inLibrary) return;
    const labels = isLibraryTab ? libraryLabels : propertyLabels;
    for (const name of labelAttributes) {
      const original = element.getAttribute(name);
      const translated = translateLabel(original, labels);
      if (translated !== original) element.setAttribute(name, translated);
    }

    const walker = document.createTreeWalker(element, NodeFilter.SHOW_TEXT);
    const textNodes = [];
    for (let text = walker.nextNode(); text; text = walker.nextNode()) {
      if (text.parentElement?.closest(userContent + ', svg, [aria-hidden="true"]')) continue;
      textNodes.push(text);
    }
    const label = textNodes.map(text => text.data).join("").trim();
    if (!labels.has(label)) return;
    const labelNode = textNodes.find(text => text.data.trim() === label);
    if (labelNode) labelNode.data = translateLabel(labelNode.data, labels);
  }

  function addControls(node, controls, descendants = false) {
    const element = node.nodeType === Node.ELEMENT_NODE ? node : node.parentElement;
    if (!element) return;
    const closest = element.closest(control);
    if (closest) controls.add(closest);
    if (descendants) element.querySelectorAll(control).forEach(item => controls.add(item));
  }

  const observer = new MutationObserver(records => {
    const controls = new Set();
    for (const record of records) {
      addControls(record.target, controls);
      for (const node of record.addedNodes) addControls(node, controls, true);
    }
    controls.forEach(translateControl);
  });

  document.querySelectorAll(control).forEach(translateControl);
  observer.observe(document.documentElement, {
    subtree: true,
    childList: true,
    characterData: true,
    attributes: true,
    attributeFilter: labelAttributes,
  });
  globalThis[installation] = observer;
})();
