/* sel2.p
 * Модуль
     BASE
 * Назначение
     вывод вертикального меню для выбора,
     выбранное значение возвращается как параметр - в отличие от sel.p, где идет return-value
 * Применение

 * Вызов
     передается заголовок и список строк меню через | , возвращается номер выбранного элемента
 * Меню


 * Автор
     nadejda
 * Дата создания:
     07.08.2003
 * Изменения
     09.10.2003 nadejda  - увеличила высоту фрейма с 5 до 8 строк

       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       07.06.2005 marinav - пустая строка между заголовком и данными (так красивее)
       02/10/2013 galina - ТЗ2104 расширила фрейм tt1
*/



def input parameter ttl as char.
def input parameter str as char.
def output parameter selitem as integer init 0.


define temp-table menu
    field num as int
    field itm as char.

def var i as int init 0.
def var dlm as char init "|".

do i = 1 to num-entries(str, dlm):
    create menu.
    assign menu.num = i menu.itm = entry(i, str, dlm).
end.

def query q1 for menu.

def browse b1
    query q1 no-lock
    display
        menu.itm label ' ' format "x(60)"
        with 8 down title ttl.

def frame fr1
    b1
    with no-labels centered overlay row 8 view-as dialog-box.

on return of b1 in frame fr1
    do:
        apply "endkey" to frame fr1.
    end.


open query q1 for each menu.

if num-results("q1") = 0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Ошибка".
    return.
end.

b1:title = ttl.
b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.

selitem = menu.num.


