<%@page import="utils.LanguageHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Include Header -->
<jsp:include page="header.jsp" />

<!-- Contact Section -->
<section class="contact-section">
    <div class="container">
        <!-- Contact Header -->
        <div class="contact-header">
            <h1><%= LanguageHelper.getText(request, "contact.title")%></h1>
            <p><%= LanguageHelper.getText(request, "contact.subtitle")%></p>
        </div>

        <div class="row">
            <!-- Contact Information -->
            <div class="col-lg-4">
                <div class="contact-info-card">
                    <img src="https://cdn-icons-png.flaticon.com/512/684/684908.png" width="50" alt="Address">
                    <h3><%= LanguageHelper.getText(request, "contact.address")%></h3>
                    <p>Đội 5, Xã Tiên Hoa, Huyện Tiên Lữ, Tỉnh Hưng Yên</p>
                </div>
                <div class="contact-info-card">
                    <img src="https://cdn-icons-png.flaticon.com/512/724/724664.png" width="50" alt="Phone">
                    <h3><%= LanguageHelper.getText(request, "contact.phone")%></h3>
                    <p><a href="tel:+8435608089">+84 35 65 08 089</a></p>
                </div>
                <div class="contact-info-card">
                    <img src="https://cdn-icons-png.flaticon.com/512/732/732200.png" width="50" alt="Email">
                    <h3><%= LanguageHelper.getText(request, "contact.email")%></h3>
                    <p><a href="mailto:support@ebooks.vn">support@ebooks.vn</a></p>
                </div>
                <div class="contact-info-card">
                    <img src="https://cdn-icons-png.flaticon.com/512/3106/3106782.png" width="50" alt="Clock">
                    <h3><%= LanguageHelper.getText(request, "contact.hours")%></h3>
                    <p><%= LanguageHelper.getText(request, "contact.hours.weekday")%><br>
                        <%= LanguageHelper.getText(request, "contact.hours.weekend")%></p>
                </div>
            </div>

            <!-- Contact Form -->
            <div class="col-lg-8">
                <div class="contact-form">
                    <form action="ContactServlet" method="POST">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="name"><%= LanguageHelper.getText(request, "contact.form.name")%></label>
                                    <input type="text" class="form-control" id="name" name="name" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="email"><%= LanguageHelper.getText(request, "contact.form.email")%></label>
                                    <input type="email" class="form-control" id="email" name="email" required>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="subject"><%= LanguageHelper.getText(request, "contact.form.subject")%></label>
                            <input type="text" class="form-control" id="subject" name="subject" required>
                        </div>
                        <div class="form-group">
                            <label for="message"><%= LanguageHelper.getText(request, "contact.form.message")%></label>
                            <textarea class="form-control" id="message" name="message" rows="5" required></textarea>
                        </div>
                        <button type="submit" class="btn btn-submit"><%= LanguageHelper.getText(request, "contact.form.send")%></button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Map Section -->
        <div class="map-container mt-5">
            <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3734.4087862967596!2d106.16782937593306!3d20.43343408102848!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3135e17fb5a8e8c9%3A0x8f8d8f8f8f8f8f8f!2zMzUzIFRy4bqnbiBIxrBuZyDEkOG6oW8sIELDoCBUcmnhu4d1LCBUaMOgbmggcGjhu5EgTmFtIMSQ4buLbmgsIE5hbSDEkOG7i25oLCBWaeG7h3QgTmFt!5e0!3m2!1svi!2s!4v1732000000000" 
                    width="600" 
                    height="450" 
                    style="border:0;" 
                    allowfullscreen="" 
                    loading="lazy" 
                    referrerpolicy="no-referrer-when-downgrade">
            </iframe>
        </div>


        <!-- FAQ Section -->
        <div class="faq-section">
            <div class="container">
                <h2 class="section-title mb-5"><%= LanguageHelper.getText(request, "contact.faq.title")%></h2>
                <div class="faq-container">
                    <div class="accordion" id="faqAccordion">
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                    <%= LanguageHelper.getText(request, "help.faq.account.question")%>
                                </button>
                            </h2>
                            <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <%= LanguageHelper.getText(request, "help.faq.account.answer")%>
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                    <%= LanguageHelper.getText(request, "help.faq.payment.methods.question")%>
                                </button>
                            </h2>
                            <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <%= LanguageHelper.getText(request, "help.faq.payment.methods.answer")%>
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                    <%= LanguageHelper.getText(request, "help.faq.download.question")%>
                                </button>
                            </h2>
                            <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <%= LanguageHelper.getText(request, "help.faq.download.answer")%>
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                                    <%= LanguageHelper.getText(request, "help.faq.refund.question")%>
                                </button>
                            </h2>
                            <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <%= LanguageHelper.getText(request, "help.faq.refund.answer")%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>  
</section>

<!-- Include Footer -->
<jsp:include page="footer.jsp" />