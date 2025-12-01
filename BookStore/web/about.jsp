<%@page import="utils.LanguageHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- Include Header -->
<jsp:include page="header.jsp" />

<main>
    <!-- Hero Section -->
    <section class="about-hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6" data-aos="fade-right">
                    <h1 class="display-4 fw-bold mb-4"><%= LanguageHelper.getText(request, "about.hero.title")%></h1>
                    <p class="lead mb-4">   <%= LanguageHelper.getText(request, "about.hero.subtitle")%></p>
                    <div class="d-flex gap-3">
                        <div class="stat-box">
                            <h3>50K+</h3>
                            <p><%= LanguageHelper.getText(request, "about.stats.readers")%></p>
                        </div>
                        <div class="stat-box">
                            <h3>100K+</h3>
                            <p><%= LanguageHelper.getText(request, "about.stats.books")%></p>
                        </div>
                        <div class="stat-box">
                            <h3>24/7</h3>
                            <p><%= LanguageHelper.getText(request, "about.stats.support")%></p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6" data-aos="fade-left">
                    <img src="images/about.jpeg" alt="About Us Hero Image" class="img-fluid rounded-4 shadow-lg">
                </div>
            </div>
        </div>
    </section>

    <!-- Mission Section -->
    <section class="mission-section">
        <div class="container">
            <div class="row g-4">
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="100">
                    <div class="mission-card">
                        <div class="icon-box">
                            <img src="https://cdn-icons-png.flaticon.com/512/929/929468.png" width="50" alt="Mission">
                        </div>
                        <h3><%= LanguageHelper.getText(request, "about.mission.title")%></h3>
                        <p><%= LanguageHelper.getText(request, "about.mission.desc")%></p>
                    </div>
                </div>
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="mission-card">
                        <div class="icon-box">
                            <img src="https://cdn-icons-png.flaticon.com/512/1022/1022397.png" width="50" alt="Vision">
                        </div>
                        <h3><%= LanguageHelper.getText(request, "about.vision.title")%></h3>
                        <p><%= LanguageHelper.getText(request, "about.vision.desc")%></p>
                    </div>
                </div>
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="mission-card">
                        <div class="icon-box">
                            <img src="https://cdn-icons-png.flaticon.com/512/929/929422.png" width="50" alt="Values">
                        </div>
                        <h3><%= LanguageHelper.getText(request, "about.values.title")%></h3>
                        <p><%= LanguageHelper.getText(request, "about.values.desc")%></p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!--    Team Section -->
    <section class="team-section">
        <div class="container">
            <h2 class="section-title text-center mb-5"><%= LanguageHelper.getText(request, "about.team.title")%></h2>
            <div class="row g-4">
                <div class="col-lg-3 col-md-6" data-aos="fade-up" data-aos-delay="100">
                    <div class="team-card">
                        <img src="images/avatar.png" alt="Team Member" class="team-img">
                        <div class="team-info">
                            <h4>Nguyễn Văn Hảo</h4>
                            <p>CEO</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6" data-aos="fade-up" data-aos-delay="400">
                    <div class="team-card">
                        <img src="images/avatar.png" alt="Team Member" class="team-img">
                        <div class="team-info">
                            <h4>Nguyễn Văn Hảo</h4>
                            <p>CEO</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6" data-aos="fade-up" data-aos-delay="300">
                    <div class="team-card">
                        <img src="images/avatar.png" alt="Team Member" class="team-img">
                        <div class="team-info">
                            <h4>Nguyễn Văn Hảo</h4>
                            <p>Co-Founder</p>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6" data-aos="fade-up" data-aos-delay="200">
                    <div class="team-card">
                        <img src="images/avatar.png" alt="Team Member" class="team-img">
                        <div class="team-info">
                            <h4>Nguyễn Văn Hảo</h4>
                            <p>Head of Technology</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Achievements Section -->
    <section class="achievements-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6" data-aos="fade-right">
                    <h2 class="section-title"><%= LanguageHelper.getText(request, "about.achievements.title")%></h2>
                    <div class="achievement-timeline">
                        <div class="timeline-item">
                            <div class="year">2023</div>
                            <div class="content">
                                <h4><%= LanguageHelper.getText(request, "about.timeline.2023.title")%></h4>
                                <p><%= LanguageHelper.getText(request, "about.timeline.2023.desc")%></p>
                            </div>
                        </div>
                        <!-- <div class="timeline-item">
                            <div class="year">2021</div>
                            <div class="content">
                                <h4>WebSite Release</h4>
                                <p>Launched our mobile application with offline reading capabilities.</p>
                            </div>
                        </div> -->
                        <div class="timeline-item">
                            <div class="year">2024</div>
                            <div class="content">
                                <h4><%= LanguageHelper.getText(request, "about.timeline.2024.title")%></h4>
                                <p><%= LanguageHelper.getText(request, "about.timeline.2024.desc")%></p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="year">2025</div>
                            <div class="content">
                                <h4><%= LanguageHelper.getText(request, "about.timeline.2025.title")%></h4>
                                <p><%= LanguageHelper.getText(request, "about.timeline.2025.desc")%></p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6" data-aos="fade-left">
                    <img src="images/book.jpg" alt="Our Achievements" class="img-fluid rounded-4 shadow-lg">
                </div>
            </div>
        </div>
    </section>
</main>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- AOS Animation -->
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
    AOS.init({
        duration: 1000,
        once: true
    });
</script>
<!-- Include Footer -->
<jsp:include page="footer.jsp" /> 