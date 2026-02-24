<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="utils.LanguageHelper" %>

<!DOCTYPE html>
<html lang="<%= "vi".equals(session.getAttribute("lang")) ? "vi" : "en"%>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= LanguageHelper.getText(request, "signup.page_title")%></title>

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <link rel="icon" type="image/png" sizes="32x32" href="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/svgs/solid/book-reader.svg">
        <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link rel="stylesheet" href="CSS/style.css">
        <link rel="stylesheet" href="CSS/signup.css">
        <style>
            .home-button {
                position: fixed;
                top: 20px;
                left: 20px;
                font-size: 24px;
                color: #333;
                text-decoration: none;
                transition: color 0.3s ease;
                z-index: 1000;
            }
            .home-button:hover {
                color: #007bff;
            }
        </style>
    </head>
    <body class="signup-page">
        <a href="index.jsp" class="home-button" title="<%= LanguageHelper.getText(request, "signup.back_home")%>">
            <i class="fas fa-arrow-left"></i>
        </a>
        <div class="signup-container">
            <div class="signup-form-container">
                <div class="signup-form">
                    <div class="text-center mb-3">
                        <a href="index.jsp" class="signup-logo">
                            <i class="fas fa-book-reader"></i>
                            <span>E-Books</span>
                        </a>
                    </div>
                    <h2 class="text-center mb-3"><%= LanguageHelper.getText(request, "signup.heading")%></h2>

                    <form class="row g-2" action="SignupServlet" method="post">
                        <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken")%>">

                        <div class="col-6">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="name" name="name" placeholder="<%= LanguageHelper.getText(request, "signup.label.fullname")%>">
                                <label for="name"><%= LanguageHelper.getText(request, "signup.label.fullname")%></label>
                                <small class="text-danger" id="nameError"></small>
                            </div>
                        </div>

                        <div class="col-6">
                            <div class="form-floating">
                                <input type="email" class="form-control" id="email" name="email" placeholder="<%= LanguageHelper.getText(request, "signup.label.email")%>">
                                <label for="email"><%= LanguageHelper.getText(request, "signup.label.email")%></label>
                                <small class="text-danger" id="emailError"></small>
                            </div>
                        </div>

                        <div class="col-6">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="contact" name="contact" placeholder="<%= LanguageHelper.getText(request, "signup.label.contact")%>">
                                <label for="contact"><%= LanguageHelper.getText(request, "signup.label.contact")%></label>
                                <small class="text-danger" id="contactError"></small>
                            </div>
                        </div>

                        <div class="col-6">
                            <div class="form-floating">
                                <div class="gender-radio-group pt-2">
                                    <label class="form-label"><%= LanguageHelper.getText(request, "signup.label.gender")%></label>&nbsp;&nbsp;&nbsp;
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="gender" id="male" value="male">
                                        <label class="form-check-label" for="male"><%= LanguageHelper.getText(request, "gender.male")%></label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="gender" id="female" value="female">
                                        <label class="form-check-label" for="female"><%= LanguageHelper.getText(request, "gender.female")%></label>
                                    </div>
                                    <small class="text-danger" id="genderError"></small>
                                </div>
                            </div>
                        </div>

                        <div class="col-12">
                            <div class="form-floating">
                                <select class="form-select" id="role" name="role">
                                    <option value=""><%= LanguageHelper.getText(request, "signup.select_role.default")%></option>
                                    <option value="User"><%= LanguageHelper.getText(request, "role.user")%></option>
                                </select>
                                <label for="role"><%= LanguageHelper.getText(request, "signup.label.role")%></label>
                                <small class="text-danger" id="roleError"></small>
                            </div>
                        </div>

                        <div class="col-6">
                            <div class="form-floating">
                                <input type="password" class="form-control" id="password" name="password" placeholder="<%= LanguageHelper.getText(request, "signup.label.password")%>">
                                <label for="password"><%= LanguageHelper.getText(request, "signup.label.password")%></label>
                                <button type="button" class="password-toggle" onclick="togglePassword('password')">
                                    <i class="far fa-eye"></i>
                                </button>
                                <small class="text-danger" id="passwordError"></small>
                            </div>
                        </div>

                        <div class="col-6">
                            <div class="form-floating">
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="<%= LanguageHelper.getText(request, "signup.label.confirm_password")%>">
                                <label for="confirmPassword"><%= LanguageHelper.getText(request, "signup.label.confirm_password")%></label>
                                <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword')">
                                    <i class="far fa-eye"></i>
                                </button>
                                <small class="text-danger" id="confirmPasswordError"></small>
                            </div>
                        </div>

                        <div class="col-12">
                            <button type="submit" class="btn btn-primary w-100"><%= LanguageHelper.getText(request, "signup.btn.submit")%></button>
                        </div>
                    </form>

                    <div class="text-center mt-3">
                        <span class="text-muted"><%= LanguageHelper.getText(request, "signup.text.have_account")%></span>
                        <a href="login.jsp" class="login-link"><%= LanguageHelper.getText(request, "signup.link.signin")%></a>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                                    const msgNameReq = "<%= LanguageHelper.getText(request, "validation.name.required")%>";
                                    const msgEmailReq = "<%= LanguageHelper.getText(request, "validation.email.required")%>";
                                    const msgEmailInv = "<%= LanguageHelper.getText(request, "validation.email.invalid")%>";
                                    const msgContactReq = "<%= LanguageHelper.getText(request, "validation.contact.required")%>";
                                    const msgContactInv = "<%= LanguageHelper.getText(request, "validation.contact.invalid")%>";
                                    const msgGenderReq = "<%= LanguageHelper.getText(request, "validation.gender.required")%>";
                                    const msgRoleReq = "<%= LanguageHelper.getText(request, "validation.role.required")%>";
                                    const msgPassReq = "<%= LanguageHelper.getText(request, "validation.password.required")%>";
                                    const msgPassLen = "<%= LanguageHelper.getText(request, "validation.password.min_length")%>";
                                    const msgConfirmPassReq = "<%= LanguageHelper.getText(request, "validation.confirm_password.required")%>";
                                    const msgPassMismatch = "<%= LanguageHelper.getText(request, "validation.password.mismatch")%>";

                                    function togglePassword(inputId) {
                                        const input = document.getElementById(inputId);
                                        const icon = input.nextElementSibling.querySelector('i');

                                        if (input.type === 'password') {
                                            input.type = 'text';
                                            icon.classList.remove('fa-eye');
                                            icon.classList.add('fa-eye-slash');
                                        } else {
                                            input.type = 'password';
                                            icon.classList.remove('fa-eye-slash');
                                            icon.classList.add('fa-eye');
                                        }
                                    }

                                    document.querySelector("form").addEventListener("submit", function (e) {
                                        let isValid = true;

                                        const name = document.getElementById("name").value.trim();
                                        const email = document.getElementById("email").value.trim();
                                        const contact = document.getElementById("contact").value.trim();
                                        const gender = document.querySelector("input[name='gender']:checked");
                                        const role = document.getElementById("role").value;
                                        const password = document.getElementById("password").value;
                                        const confirmPassword = document.getElementById("confirmPassword").value;

                                        document.querySelectorAll("small.text-danger").forEach(el => el.textContent = "");

                                        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                                        const contactRegex = /^[0-9]{10}$/;

                                        if (name === "") {
                                            document.getElementById("nameError").textContent = msgNameReq;
                                            isValid = false;
                                        }

                                        if (email === "") {
                                            document.getElementById("emailError").textContent = msgEmailReq;
                                            isValid = false;
                                        } else if (!emailRegex.test(email)) {
                                            document.getElementById("emailError").textContent = msgEmailInv;
                                            isValid = false;
                                        }

                                        if (contact === "") {
                                            document.getElementById("contactError").textContent = msgContactReq;
                                            isValid = false;
                                        } else if (!contactRegex.test(contact)) {
                                            document.getElementById("contactError").textContent = msgContactInv;
                                            isValid = false;
                                        }

                                        if (!gender) {
                                            document.getElementById("genderError").textContent = msgGenderReq;
                                            isValid = false;
                                        }

                                        if (role === "") {
                                            document.getElementById("roleError").textContent = msgRoleReq;
                                            isValid = false;
                                        }

                                        if (password === "") {
                                            document.getElementById("passwordError").textContent = msgPassReq;
                                            isValid = false;
                                        } else if (password.length < 6) {
                                            document.getElementById("passwordError").textContent = msgPassLen;
                                            isValid = false;
                                        }

                                        if (confirmPassword === "") {
                                            document.getElementById("confirmPasswordError").textContent = msgConfirmPassReq;
                                            isValid = false;
                                        } else if (password !== confirmPassword) {
                                            document.getElementById("confirmPasswordError").textContent = msgPassMismatch;
                                            isValid = false;
                                        }
                   
                                        if (!isValid) {
                                            e.preventDefault();
                                        }
                                    });
        </script>

    </body>
</html>