window.addEventListener("load", initialize);
window.channel = window.executeCommand("get-channel");

function sleep(milliseconds) {
    return new Promise(resolve => {
        setTimeout(resolve, milliseconds);
    });
}

function makeSleep(milliseconds) {
    return () => sleep(milliseconds);
}

function waitForAllImages() {
    return new Promise(resolve => {
        function waitForAllImagesInternal() {
            const images = document.querySelectorAll('img');

            for (var i = 0; i < images.length; ++i) {
                if (!images[i].complete) {
                    window.requestAnimationFrame(waitForAllImagesInternal);
                    return;
                }
            }

            resolve();
        }

        waitForAllImagesInternal();
    });
}

function addStyleElement(css) {
    var head = document.head || document.getElementsByTagName('head')[0],
        style = document.createElement('style');

    head.appendChild(style);

    style.type = 'text/css';
    if (style.styleSheet) {
        // This is required for IE8 and below.
        style.styleSheet.cssText = css;
    } else {
        style.appendChild(document.createTextNode(css));
    }
}

function getOtherChannel(channel) {
    if (channel == "main") {
        return "dev";
    }
    return "main";
}

function adjustChannelElements() {
    window.channel.then(channel => {
        addStyleElement(`.channel-${getOtherChannel(channel)}{display: none;}`);
    });
}

function initialize() {
    initializeNavigation() //
        .then(() => waitForAllImages()) //
        .then(makeSleep(300))
        .then(() => window.executeCommand("show"));

    document.querySelector("#minimize-button").onclick = () => {
        window.executeCommand("minimize");
    };

    document.querySelector("#close-button").onclick = () => {
        window.executeCommand("close");
    };

    adjustChannelElements();
}

window.showSettings = function() {
    document.querySelector("#navigation>#settings.element").click();
}

function initializeNavigation() {
    var elements = document.querySelectorAll("#navigation>.element");
    elements.forEach(e => {
        e.addEventListener("click", handleNavigationClick);
    });

    return loadInitialPage();
}

function removeActiveElement() {
    var element = document.querySelector("#navigation>.element.active");
    if (element) {
        element.classList.remove("active");
    }
}

function handleNavigationClick(e) {
    const el = this;
    if (el.classList.contains("active")) {
        return;
    }

    removeActiveElement();
    el.classList.add("active");
    loadNavigationPage(el.id);
}

function loadInitialPage() {
    const el = document.querySelector("#navigation>.element.active");
    return loadNavigationPage(el.id);
}

function setInnerHTML(elm, html) {
    elm.innerHTML = html;
    Array.from(elm.querySelectorAll("script")).forEach(oldScript => {
        const newScript = document.createElement("script");
        Array.from(oldScript.attributes)
            .forEach(attr => newScript.setAttribute(attr.name, attr.value));
        newScript.appendChild(document.createTextNode(oldScript.innerHTML));
        oldScript.parentNode.replaceChild(newScript, oldScript);
    });
}

function loadNavigationPage(page) {
    var content = document.querySelector("#content");
    return fetch(`./pages/${page}.html`).then(data => {
        return data.text()
    }).then(text => {
        setInnerHTML(content, text);
    });
}