// mikey-macros docs: the "On this page" sidebar.
// Highlights the section you're reading, keeps it in view in the sidebar, and
// collapses the list into a dropdown on narrow screens.
(() => {
    const toc = document.querySelector(".page-toc");
    if (!toc) return;
    const details = toc.querySelector("details");
    const wide = window.matchMedia("(min-width: 900px)");

    // Open on wide screens, closed (a dropdown) on narrow ones.
    const fit = () => { details.open = wide.matches; };
    fit();
    wide.addEventListener("change", fit);

    // On narrow screens, picking a section closes the dropdown.
    toc.addEventListener("click", (e) => {
        if (e.target.closest("a") && !wide.matches) details.open = false;
    });

    const links = new Map();
    toc.querySelectorAll('a[href^="#"]').forEach((a) => links.set(decodeURIComponent(a.hash.slice(1)), a));
    const headings = [...document.querySelectorAll("main h2[id], main h3[id]")].filter((h) => links.has(h.id));
    let current = null;

    const show = (id) => {
        if (id === current) return;
        current = id;
        toc.querySelectorAll(".active, .within").forEach((el) => el.classList.remove("active", "within"));
        const a = links.get(id);
        if (!a) return;
        a.classList.add("active");
        // a sub-section also marks its section
        const parent = a.closest("ul ul")?.closest("li")?.querySelector(":scope > a");
        if (parent) parent.classList.add("within");
        if (wide.matches) {
            const r = a.getBoundingClientRect();
            const box = details.getBoundingClientRect();
            if (r.top < box.top || r.bottom > box.bottom) a.scrollIntoView({ block: "nearest" });
        }
    };

    // The current section is the last heading above the top quarter of the window.
    const update = () => {
        const line = window.innerHeight * 0.25;
        let id = headings.length ? headings[0].id : null;
        for (const h of headings) {
            if (h.getBoundingClientRect().top <= line) id = h.id;
            else break;
        }
        // at the very bottom, the last section wins
        if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2 && headings.length) {
            id = headings[headings.length - 1].id;
        }
        show(id);
    };
    let queued = false;
    window.addEventListener("scroll", () => {
        if (queued) return;
        queued = true;
        requestAnimationFrame(() => { queued = false; update(); });
    }, { passive: true });
    window.addEventListener("resize", update);
    update();
})();
