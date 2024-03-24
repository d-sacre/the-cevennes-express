//derived from: https://codepen.io/dcode-software/pen/eYMYXrK
document.querySelectorAll(".copy-link").forEach((copyLinkParent) => {
    const heading = copyLinkParent.querySelector(".copy-link-heading");
    const copyButton = copyLinkParent.querySelector(".copy-link-button");

    copyButton.addEventListener("click", () => {
        const currentUrl = window.location.href;
        const currentID = heading.id
        const refUrl = currentUrl + "#" + currentID
        console.log(refUrl)
        navigator.clipboard.writeText(refUrl);

        copyButton.innerText = "Copied!";
        setTimeout(() => (copyButton.innerText = "Copy Link"), 2000);
    });
});