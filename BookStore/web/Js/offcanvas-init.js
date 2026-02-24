
(function () {
    'use strict';

    function safe(fn) {
        try {
            fn();
        } catch (e) {
            console && console.error && console.error('offcanvas-init error', e);
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        safe(function () {
            var offcanvasEl = document.getElementById('mobileMenu');
            if (!offcanvasEl)
                return;
            if (typeof bootstrap === 'undefined' || !bootstrap.Offcanvas)
                return;

            var bsOff = bootstrap.Offcanvas.getInstance(offcanvasEl);
            if (!bsOff)
                bsOff = new bootstrap.Offcanvas(offcanvasEl);


            offcanvasEl.addEventListener('click', function (e) {
                var link = e.target.closest && e.target.closest('.nav-link');
                if (link) {
                    setTimeout(function () {
                        try {
                            bsOff.hide();
                        } catch (err) {
                        }
                    }, 120);
                }
            });


            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape' && bsOff && typeof bsOff.hide === 'function') {
                    try {
                        bsOff.hide();
                    } catch (err) {
                    }
                }
            });

            var togglers = document.querySelectorAll('[data-bs-toggle="offcanvas"][data-bs-target="#mobileMenu"]');
            Array.prototype.forEach.call(togglers, function (btn) {
                btn.addEventListener('click', function () {

                });
            });
        });
    });
})();