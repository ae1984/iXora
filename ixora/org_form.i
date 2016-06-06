/* org_form.i
 * MODULE
        Сопастовление организационных форм
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        17.07.2013 yerganat
 * CHANGES
*/

def temp-table t-org_form no-undo
  field org_id as char /*В конце файла указан описания*/
  field lnopf_id as char  /*id из codfr*/
  field lnopf_name as char.


create t-org_form.
assign t-org_form.org_id = '30'
       t-org_form.lnopf_id = '0'
       t-org_form.lnopf_name = 'Оптовая торговля'.

create t-org_form.
assign t-org_form.org_id = '10'
       t-org_form.lnopf_id = '1'
       t-org_form.lnopf_name = 'Государственное предприятие'.

create t-org_form.
assign t-org_form.org_id = '18'
       t-org_form.lnopf_id = '2'
       t-org_form.lnopf_name = 'Полное товарищество'.

create t-org_form.
assign t-org_form.org_id = '19'
       t-org_form.lnopf_id = '3'
       t-org_form.lnopf_name = 'Коммандитное товарищество'.

create t-org_form.
assign t-org_form.org_id = '20'
       t-org_form.lnopf_id = '4'
       t-org_form.lnopf_name = 'Товарищество с ограниченной ответственностью'.

create t-org_form.
assign t-org_form.org_id = '21'
       t-org_form.lnopf_id = '5'
       t-org_form.lnopf_name = 'Товарищество с дополнительной ответственностью'.

create t-org_form.
assign t-org_form.org_id = '28'
       t-org_form.lnopf_id = '6'
       t-org_form.lnopf_name = 'Акционерное общество (коммерческая организация)'.

create t-org_form.
assign t-org_form.org_id = '31'
       t-org_form.lnopf_id = '7'
       t-org_form.lnopf_name = 'Производственный кооператив'.

create t-org_form.
assign t-org_form.org_id = '35'
       t-org_form.lnopf_id = '8'
       t-org_form.lnopf_name = 'Учреждение'.

create t-org_form.
assign t-org_form.org_id = '10'
       t-org_form.lnopf_id = '9'
       t-org_form.lnopf_name = 'Государственное учреждение'.

create t-org_form.
assign t-org_form.org_id = '36'
       t-org_form.lnopf_id = '10'
       t-org_form.lnopf_name = 'Общественное объединение'.

create t-org_form.
assign t-org_form.org_id = '28'
       t-org_form.lnopf_id = '11'
       t-org_form.lnopf_name = 'Акционерное общество (некоммерческая организация)'.

create t-org_form.
assign t-org_form.org_id = '37'
       t-org_form.lnopf_id = '12'
       t-org_form.lnopf_name = 'Потребительский кооператив'.

create t-org_form.
assign t-org_form.org_id = '38'
       t-org_form.lnopf_id = '13'
       t-org_form.lnopf_name = 'Общественный фонд'.

create t-org_form.
assign t-org_form.org_id = '39'
       t-org_form.lnopf_id = '14'
       t-org_form.lnopf_name = 'Религиозное объединение'.

create t-org_form.
assign t-org_form.org_id = '42'
       t-org_form.lnopf_id = '15'
       t-org_form.lnopf_name = 'Крестьянское хозяйство'.

create t-org_form.
assign t-org_form.org_id = '30'
       t-org_form.lnopf_id = '16'
       t-org_form.lnopf_name = 'Иные формы, предусмотренные законодательными актами'.

create t-org_form.
assign t-org_form.org_id = '30'
       t-org_form.lnopf_id = 'msc'
       t-org_form.lnopf_name = 'Остальные'.


/*
Справочник Организационно правовых форм.

Код	Наименование
42	Сельскохозяйственные товарищества
40	Объединения  юридических лиц в форме  ассоциации
39	Религиозные объединения
31	Производственные кооперативы
30	Другие организационно-правовые формы
28	Акционерные общества
21	Товарищества с дополнительной ответственностью
20	Товарищества с ограниченной ответственностью
19	Коммандитные  товарищества
18	Полные товарищества
15	Хозяйственные товарищества
12	Государственные предприятия на праве оперативного управления  (казенные)
11	Государственные предприятия на праве хозяйственного ведения
10	Государственные предприятия
38	Фонды
37	Потребительские кооперативы
36	Общественные объединения
35	Учреждения
60	Иные организационно-правовые формы некоммерческой организации
50	Семейное предпринимательство
49	Предпринимательство супругов
48	Простое товарищество
47	Индивидуальное предпринимательство на основе совместного предпринимательства
46	Личное предпринимательство
45	Индивидуальное предпринимательство

*/