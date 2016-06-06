/* docctrl.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
        09.08.2004 dpuchkov - добавил отображение курсов валют при контроле
 * CHANGES
        11.07.2005 dpuchkov- добавил формирование корешка
        29.06.2011 Luiza - Добавила вывод наименования для арп счетов, переменные v-desdracc и v-descracc
        11/10/2011 Luiza - Добавила вывод суммы комиссии v-comamt
        14/12/2011 evseev - ТЗ-625. Переход на ИИН/БИН
        27.08.2012 evseev - иин/бин
*/


form v-ref label "НомерДок" space(10) v-who label "Исполнил" skip
v-dracc label "СчетД" space(8)  v-cracc label "СчетК" skip
v-desdracc no-label format "x(30)" space(6) v-descracc no-label format "x(30)" skip
v-dramt label "СуммаД" space(7) v-cramt label "СуммаК" skip
v-drcrc label "ВалД" space(28)
v-crcrc label "ВалК" skip
v-transf label "НомПеревода" skip
v-comamt label "Сум.комисс " skip
v-det[1] label "ДеталиПл" skip
v-det[2] label "ДеталиПл" skip
v-det[3] label "ДеталиПл" skip
v-det[4] label "ДеталиПл" skip
v-jss    label "ИИН/БИН" skip
v-pass   label "Уд/Личн " skip
v-fio    label "Ф.И.О   "


 with frame con  side-label row 9  centered  .



form v-ref label "НомерДок" space(10) v-who label "Исполнил" skip
v-dracc label "СчетД" space(10)  v-cracc label "СчетК" skip
v-desdracc no-label format "x(30)" space(6) v-descracc no-label format "x(30)" skip
v-dramt label "СуммаД" space(7) v-cramt label "СуммаК" skip
v-drcrc label "ВалД" space(28)
v-crcrc label "ВалК" skip
v-transf label "НомПеревода" skip
v-comamt label "Сум.комисс " skip
v-brate label "Курс покупки" format 'zzz,zzz,zzz,zz9.99' space(28)
v-srate label "Курс продажи" format 'zzz,zzz,zzz,zz9.99'  skip
v-det[1] label "ДеталиПл" skip
v-det[2] label "ДеталиПл" skip
v-det[3] label "ДеталиПл" skip
v-det[4] label "ДеталиПл"

 with frame con1  side-label row 9  centered  .
