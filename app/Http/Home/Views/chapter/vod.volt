{% extends 'templates/main.volt' %}

{% block content %}

    {% set full_chapter_url = full_url({'for':'home.chapter.show','id':chapter.id}) %}
    {% set course_url = url({'for':'home.course.show','id':chapter.course.id}) %}
    {% set resources_url = url({'for':'home.chapter.resources','id':chapter.id}) %}
    {% set learning_url = url({'for':'home.chapter.learning','id':chapter.id}) %}
    {% set like_url = url({'for':'home.chapter.like','id':chapter.id}) %}
    {% set qrcode_url = url({'for':'home.qrcode'},{'text':full_chapter_url}) %}
    {% set consult_url = url({'for':'home.consult.add'},{'chapter_id':chapter.id}) %}
    {% set liked_class = chapter.me.liked ? 'active' : '' %}

    <div class="breadcrumb">
        <span class="layui-breadcrumb">
            <a href="{{ course_url }}"><i class="layui-icon layui-icon-return"></i> 返回课程</a>
            <a><cite>{{ chapter.course.title }}</cite></a>
            <a><cite>{{ chapter.title }}</cite></a>
        </span>
        <span class="share">
            <a href="javascript:" title="我要点赞" data-url="{{ like_url }}"><i class="layui-icon layui-icon-praise icon-praise {{ liked_class }}"></i><em class="like-count">{{ chapter.like_count }}</em></a>
            <a href="javascript:" title="学习人次"><i class="layui-icon layui-icon-user"></i><em>{{ chapter.user_count }}</em></a>
            <a href="javascript:" title="我要提问" data-url="{{ consult_url }}"><i class="layui-icon layui-icon-help icon-help"></i></a>
            {% if chapter.resource_count > 0 and chapter.me.owned == 1 %}
                <a href="javascript:" title="资料下载" data-url="{{ resources_url }}"><i class="layui-icon layui-icon-download-circle icon-resource"></i></a>
            {% endif %}
            <a href="javascript:" title="分享到微信"><i class="layui-icon layui-icon-login-wechat icon-wechat"></i></a>
            <a href="javascript:" title="分享到QQ空间"><i class="layui-icon layui-icon-login-qq icon-qq"></i></a>
            <a href="javascript:" title="分享到微博"><i class="layui-icon layui-icon-login-weibo icon-weibo"></i></a>
        </span>
    </div>

    <div class="layout-main clearfix">
        <div class="layout-content">
            <div class="player-wrap wrap">
                <div id="player"></div>
            </div>
        </div>
        <div class="layout-sidebar">
            {{ partial('chapter/catalog') }}
        </div>
    </div>

    <div class="layui-hide">
        <input type="hidden" name="chapter.id" value="{{ chapter.id }}">
        <input type="hidden" name="chapter.position" value="{{ chapter.me.position }}">
        <input type="hidden" name="chapter.plan_id" value="{{ chapter.me.plan_id }}">
        <input type="hidden" name="chapter.learning_url" value="{{ learning_url }}">
        <input type="hidden" name="chapter.play_urls" value='{{ chapter.play_urls|json_encode }}'>
    </div>

    <div class="layui-hide">
        <input type="hidden" name="share.title" value="{{ chapter.course.title }}">
        <input type="hidden" name="share.pic" value="{{ chapter.course.cover }}">
        <input type="hidden" name="share.url" value="{{ full_chapter_url }}">
        <input type="hidden" name="share.qrcode" value="{{ qrcode_url }}">
    </div>

{% endblock %}

{% block include_js %}

    {{ js_include('https://imgcache.qq.com/open/qcloud/video/vcplayer/TcPlayer-2.3.3.js', false) }}
    {{ js_include('home/js/course.share.js') }}
    {{ js_include('home/js/chapter.action.js') }}
    {{ js_include('home/js/chapter.vod.player.js') }}

{% endblock %}