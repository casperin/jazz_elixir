window.addEventListener("keydown", function (e) {
    if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") {
        return
    }

    switch (e.key) {
        case "j":
            return move(1)
        case "k":
            return move(-1)
        case "/":
            if (search_item) {
                search_item.focus()
                e.preventDefault()
            }
            break
        case "U":
        case "1":
            return document.location.href = "/"
        case "S":
        case "2":
            return document.location.href = "/posts/saved"
        case "P":
        case "3":
            return document.location.href = "/posts/podcasts"
        case "L":
        case "4":
            return document.location.href = "/links"
        case "N":
        case "5":
            return document.location.href = "/notes"
        case "F":
        case "6":
            return document.location.href = "/feeds"
    }

    const classes = {
        r: '.set-read',
        s: '.toggle-save',
        p: '.toggle-podcast'
    }
    if (e.key in classes) {
        var items = Array.from(document.querySelectorAll(".item, .content a"))
        var link = items[focused] && items[focused].parentElement.querySelector(classes[e.key])
        if (link) {
            localStorage.setItem("focused", focused)
            link.click()
        }
    }
})

var focused =  Number(localStorage.getItem("focused")) || -1
var all_items = Array.from(document.querySelectorAll(".item, .content a"))
if (all_items[focused]) {
    all_items[focused].focus()
    localStorage.removeItem("focused")
}

all_items.forEach((item, i) => {
    item.addEventListener("focus", function() {
        focused = i
    })
})

function move(dx) {
    var items = Array.from(document.querySelectorAll(".item, .content a"))
    var last_index = items.length - 1
    focused += dx
    if (focused < 0 || focused > last_index) {
        focused = dx > 0 ? 0 : last_index
    }
    var item = items[focused]
    if (item.tagName === "A") {
        item.focus()
    } else {
        var a = item.querySelector("a")
        if (a) a.focus()
    }
}

var search_item = document.querySelector(".search_item")

if (search_item) {
    filter(search_item.value)
    search_item.addEventListener("input", e => filter(e.target.value))
}

function filter(value) {
    value = value.trim()
    var item, hide_item
    for (item of all_items) {
        hide_item = item.getAttribute("data-text").indexOf(value) === -1
        item.classList.toggle("hide", hide_item)
    }
}

var pos = sessionStorage.getItem("scroll-position")
if (pos) {
    window.scrollTo(0, pos)
    sessionStorage.removeItem("scroll-position")
}

document.body.addEventListener("click", function (e) {
    if (e.target.getAttribute("data-keep-scroll-position")) {
        sessionStorage.setItem("scroll-position", window.scrollY)
    }
})