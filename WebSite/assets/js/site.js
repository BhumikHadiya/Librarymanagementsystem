// ===== Library Management System - client-side helpers =====
document.addEventListener("DOMContentLoaded", function () {

    // --- Mobile sidebar toggle ---
    var sidebar = document.getElementById("sidebar");
    var backdrop = document.getElementById("sidebarBackdrop");
    var toggle = document.getElementById("sidebarToggle");
    if (sidebar && toggle) {
        toggle.addEventListener("click", function () {
            sidebar.classList.toggle("show");
            backdrop.classList.toggle("show");
        });
        backdrop.addEventListener("click", function () {
            sidebar.classList.remove("show");
            backdrop.classList.remove("show");
        });
    }

    // --- Instant table filter ---
    // <input data-table-filter="IdOfTable"> hides rows that do not contain the typed text.
    var filters = document.querySelectorAll("[data-table-filter]");
    filters.forEach(function (input) {
        input.addEventListener("input", function () {
            var table = document.getElementById(input.getAttribute("data-table-filter"));
            if (!table || !table.tBodies.length) return;
            var text = input.value.trim().toLowerCase();
            Array.prototype.forEach.call(table.tBodies[0].rows, function (row) {
                if (row.classList.contains("grid-pager")) return;
                row.style.display = row.textContent.toLowerCase().indexOf(text) > -1 ? "" : "none";
            });
        });
    });

    // --- Auto-hide success messages after 5 seconds ---
    setTimeout(function () {
        document.querySelectorAll(".alert-success.alert-dismissible").forEach(function (el) {
            if (window.bootstrap) bootstrap.Alert.getOrCreateInstance(el).close();
        });
    }, 5000);
});

// Used by delete buttons: OnClientClick="return confirmDelete('book');"
function confirmDelete(what) {
    return confirm("Are you sure you want to delete this " + what + "? This cannot be undone.");
}
