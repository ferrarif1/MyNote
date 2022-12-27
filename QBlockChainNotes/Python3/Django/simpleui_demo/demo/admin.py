import datetime

from django.contrib import admin, messages
from django.db import transaction
from django.urls import reverse

from .models import *
from import_export import resources
from import_export.admin import ImportExportModelAdmin, ImportExportActionModelAdmin


# Register your models here.
@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    # 要显示的字段
    list_display = ('id', 'name', 'create_time')

    # 需要搜索的字段
    search_fields = ('name',)

    # 分页显示，一页的数量
    list_per_page = 10

    actions_on_top = True


class ImageInline(admin.TabularInline):
    model = Image


@admin.register(Title)
class TitleAdmin(admin.ModelAdmin):
    # 要显示的字段
    list_display = ('id', 'name')

    # 需要搜索的字段
    search_fields = ('name',)

    # 分页显示，一页的数量
    list_per_page = 10
    inlines = [
        ImageInline,
    ]


class AgeListFilter(admin.SimpleListFilter):
    title = u'最近生日'
    parameter_name = 'ages'

    def lookups(self, request, model_admin):
        return (
            ('0', u'最近7天'),
            ('1', u'最近15天'),
            ('2', u'最近30天'),
        )

    def queryset(self, request, queryset):
        # 当前日期格式
        cur_date = datetime.datetime.now().date()

        if self.value() == '0':
            # 前一天日期
            day = cur_date - datetime.timedelta(days=1)

            return queryset.filter(birthday__gte=day)
        if self.value() == '1':
            day = cur_date - datetime.timedelta(days=15)
            return queryset.filter(birthday__gte=day)
        if self.value() == '2':
            day = cur_date - datetime.timedelta(days=30)
            return queryset.filter(birthday__gte=day)


class ProxyResource(resources.ModelResource):
    class Meta:
        model = Employe


@admin.register(Employe)
class EmployeAdmin(ImportExportActionModelAdmin):
    resource_class = ProxyResource
    list_display = ('id', 'name', 'gender', 'phone', 'birthday', 'department', 'enable', 'create_time')
    # search_fields = ('name', 'enable', 'idCard', 'department')
    search_fields = ('name', 'department__name')
    list_per_page = 20
    raw_id_fields = ('department', 'title')
    list_filter = ('department', AgeListFilter, 'create_time')
    # list_filter = (AgeListFilter, 'department', 'create_time', 'birthday', 'time', 'enable', 'gender')

    list_display_links = ('name',)

    list_editable = ('department', 'phone', 'birthday', 'enable', 'gender')

    date_hierarchy = 'create_time'

    fieldsets = [(None, {'fields': ['name', 'gender', 'phone']}),
                 (u'其他信息', {
                     'classes': ('123',),
                     'fields': ['birthday', 'department', 'enable']})]

    @transaction.atomic
    def test(self, request, queryset):
        messages.add_message(request, messages.SUCCESS, '啥也没有~')
        pass

    # 自 3.4+ 支持confirm确认提示
    test.confirm = '您确定要点击测试按钮吗？'

    # 增加自定义按钮
    actions = [test, 'make_copy', 'custom_button']

    def custom_button(self, request, queryset):
        pass

    # 显示的文本，与django admin一致
    custom_button.short_description = '测试按钮'
    # icon，参考element-ui icon与https://fontawesome.com
    custom_button.icon = 'fas fa-audio-description'

    # 指定element-ui的按钮类型，参考https://element.eleme.cn/#/zh-CN/component/button
    custom_button.type = 'danger'

    # 给按钮追加自定义的颜色
    custom_button.style = 'color:black;'

    # 链接按钮，设置之后直接访问该链接
    # 3中打开方式
    # action_type 0=当前页内打开，1=新tab打开，2=浏览器tab打开
    # 设置了action_type，不设置url，页面内将报错

    custom_button.action_type = 1
    custom_button.action_url = 'https://www.baidu.com'

    def make_copy(self, request, queryset):
        ids = request.POST.getlist('_selected_action')
        for id in ids:
            employe = Employe.objects.get(id=id)

            Employe.objects.create(
                name=employe.name,
                idCard=employe.idCard,
                phone=employe.phone,
                birthday=employe.birthday,
                department_id=employe.department_id
            )

        messages.add_message(request, messages.SUCCESS, '复制成功，复制了{}个员工。'.format(len(ids)))

    make_copy.short_description = '复制员工'
