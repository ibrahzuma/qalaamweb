import os

def write_templates():
    detail_content = """{% extends 'base.html' %}
{% block title %}{{ dua.title }} - QALAAM{% endblock %}
{% block extra_css %}
<!-- Load Amiri font from Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400;1,700&display=swap" rel="stylesheet">
<style>
    .dua-arabic { 
        font-family: 'Amiri', serif; 
        font-size: 2.5rem; 
        line-height: normal; 
        direction: rtl; 
        color: var(--primary-color); 
        background-color: #fcfcfc; 
        border-right: 5px solid var(--primary-color); 
        word-spacing: 5px;
    }
    .dua-section-title { 
        text-transform: uppercase; 
        letter-spacing: 1px; 
        font-size: 0.9rem; 
        color: #999; 
        font-weight: 600; 
        margin-bottom: 0.5rem; 
    }
    [lang="ar"] {
        font-family: 'Amiri', serif;
    }
</style>
{% endblock %}
{% block content %}
<nav aria-label="breadcrumb" class="mb-4 mt-4">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="{% url 'home' %}" class="text-decoration-none">Home</a></li>
        <li class="breadcrumb-item"><a href="{% url 'duas:dua_list' %}" class="text-decoration-none">Duas</a></li>
        <li class="breadcrumb-item active">{{ dua.title }}</li>
    </ol>
</nav>
<div class="row justify-content-center">
    <div class="col-lg-10">
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-5">
            <div class="card-body p-5">
                <div class="text-center mb-5">
                    <span class="badge bg-light text-primary rounded-pill px-3 py-2 mb-3">{{ dua.category.name }}</span>
                    <h1 class="display-4 fw-bold mb-3">{{ dua.title }}</h1>
                    {% if dua.reference %}<p class="text-muted italic">Reference: {{ dua.reference }}</p>{% endif %}
                </div>
                <!-- Added lang="ar" and dir="rtl" to container -->
                <div class="mb-5 p-5 dua-arabic text-center shadow-sm rounded-4 position-relative" lang="ar" dir="rtl">
                    {{ dua.arabic_text }}
                    <button class="btn btn-sm btn-light position-absolute top-0 end-0 m-3 rounded-pill shadow-sm" onclick="copyArabicOnly()" title="Copy Arabic Only"><i class="bi bi-clipboard"></i></button>
                </div>
                {% if dua.audio_url or dua.audio_file %}
                <div class="mb-5 p-4 bg-light rounded-4 shadow-sm text-center">
                    <div class="dua-section-title mb-3">Listen to Recitation</div>
                    <audio controls class="w-100">
                        <source src="{% if dua.audio_file %}{{ dua.audio_file.url }}{% else %}{{ dua.audio_url }}{% endif %}" type="audio/mpeg">
                        Your browser does not support the audio element.
                    </audio>
                </div>
                {% endif %}
                <hr class="my-5 opacity-25">
                {% if dua.transliteration %}
                <div class="mb-5">
                    <div class="dua-section-title">Transliteration</div>
                    <p class="fs-5 text-muted fst-italic lh-base">{{ dua.transliteration }}</p>
                </div>
                {% endif %}
                <div class="mb-5">
                    <div class="dua-section-title">Translation</div>
                    <p class="fs-4 lh-base">{{ dua.translation }}</p>
                </div>
                <div class="mt-5 pt-4 text-center">
                    <button class="btn btn-primary rounded-pill px-5 py-3 shadow-sm mb-2" onclick="window.print()"><i class="bi bi-printer me-2"></i> Print this Dua</button>
                    <button class="btn btn-outline-secondary rounded-pill px-5 py-3 shadow-sm ms-md-2 mb-2" onclick="copyToClipboard()"><i class="bi bi-clipboard me-2"></i> Copy Full Text</button>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="copyToast" class="toast align-items-center text-white bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex"><div class="toast-body">Text copied to clipboard!</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button></div>
    </div>
</div>
<script>
    function showToast() { const toastEl = document.getElementById('copyToast'); const toast = new bootstrap.Toast(toastEl); toast.show(); }
    function copyToClipboard() { const text = `{{ dua.title }}\\n\\n{{ dua.arabic_text }}\\n\\nTranslation:\\n{{ dua.translation }}`; navigator.clipboard.writeText(text).then(() => { showToast(); }); }
    function copyArabicOnly() { const text = `{{ dua.arabic_text }}`; navigator.clipboard.writeText(text).then(() => { showToast(); }); }
</script>
{% endblock %}"""

    list_content = """{% extends 'base.html' %}
{% block title %}Supplications (Duas) - QALAAM{% endblock %}
{% block extra_css %}
<!-- Load Amiri font from Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Amiri&display=swap" rel="stylesheet">
<style>
    .category-sidebar { border-radius: 15px; background: white; padding: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
    .category-item { padding: 10px 15px; border-radius: 10px; transition: all 0.3s; color: #555; text-decoration: none; display: block; margin-bottom: 5px; }
    .category-item:hover { background-color: var(--secondary-color); color: var(--primary-color); transform: translateX(5px); }
    .category-item.active { background-color: var(--primary-color); color: white; }
    .dua-card { border-radius: 15px; transition: all 0.3s; border: none; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
    .dua-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
    .dua-arabic-preview { font-family: 'Amiri', serif; font-size: 1.5rem; color: var(--primary-color); direction: rtl; }
</style>
{% endblock %}
{% block content %}
<div class="container py-5">
    <div class="row mb-5 text-center">
        <div class="col-lg-8 mx-auto">
            <h1 class="display-4 fw-bold mb-3">Supplications</h1>
            <p class="lead text-muted">A collection of duas from the Quran and Sunnah.</p>
            <form method="GET" action="{% url 'duas:dua_list' %}" class="mt-4">
                <div class="input-group input-group-lg shadow-sm rounded-pill overflow-hidden">
                    <input type="text" name="search" class="form-control border-0 px-4" placeholder="Search for a dua..." value="{{ request.GET.search }}">
                    <button class="btn btn-primary px-4" type="submit"><i class="bi bi-search"></i></button>
                </div>
            </form>
        </div>
    </div>
    <div class="row">
        <div class="col-md-3 mb-4">
            <div class="category-sidebar">
                <h5 class="fw-bold mb-3">Categories</h5>
                <a href="{% url 'duas:dua_list' %}" class="category-item {% if not current_category %}active{% endif %}">All Categories</a>
                {% for cat in categories %}
                <a href="?category={{ cat.slug }}" class="category-item {% if current_category.slug == cat.slug %}active{% endif %}">{{ cat.name }}</a>
                {% endfor %}
            </div>
        </div>
        <div class="col-md-9">
            <div class="row g-4">
                {% for dua in duas %}
                <div class="col-md-6">
                    <div class="card h-100 dua-card p-2">
                        <div class="card-body d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <span class="badge bg-light text-primary rounded-pill">{{ dua.category.name }}</span>
                                {% if dua.audio_url or dua.audio_file %}<i class="bi bi-volume-up-fill text-primary"></i>{% endif %}
                            </div>
                            <h5 class="card-title fw-bold mb-3">{{ dua.title }}</h5>
                            <p class="dua-arabic-preview text-truncate mb-3" lang="ar" dir="rtl">{{ dua.arabic_text }}</p>
                            <p class="card-text text-muted small flex-grow-1">{{ dua.translation|truncatewords:20 }}</p>
                            <a href="{% url 'duas:dua_detail' dua.slug %}" class="btn btn-outline-primary rounded-pill mt-3 w-100 stretched-link">View Dua</a>
                        </div>
                    </div>
                </div>
                {% empty %}
                <div class="col-12 text-center py-5">
                    <i class="bi bi-search display-1 text-muted opacity-25"></i>
                    <h3 class="mt-3">No duas found matching your search.</h3>
                </div>
                {% endfor %}
            </div>
        </div>
    </div>
</div>
{% endblock %}"""

    with open('templates/duas/dua_detail.html', 'w', encoding='utf-8') as f:
        f.write(detail_content)
    with open('templates/duas/dua_list.html', 'w', encoding='utf-8') as f:
        f.write(list_content)
    print("Templates written successfully.")

if __name__ == "__main__":
    write_templates()
