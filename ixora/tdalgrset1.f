/* tdalgrset.f
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
    22/08/03 nataly изменен формат aaa.pri , pri.pri c "x(1)"  - > "x(3)"
    21/07/04 dpuchkov -  изменил формат отображения для выплаты проц.
    19/01/2011 evseev - изменил формат lgr.dueday с z9 на z99
*/

def var v-comiss as char.

form lgr.lgr label "Код " format "x(3)"
     lgr.des label "Описание группы" format "x(40)"
     lgr.gl label "Сч. Г/К" format "zzzzzz"
            help "Введите счет Главной книги; F2 - помощь"
     validate(can-find(gl where gl.gl = lgr.gl and gl.subled = "cif" and gl.level = 1),
              "Должен быть счет Г/К с подкнигой CIF 1-го уровня!")
     lgr.crc label "Вал" format "z9"
             validate(can-find(crc where crc.crc = lgr.crc and crc.sts <> 9)
                     ,"Валюта с таким кодом не существует или закрыта!")
             help "Введите код валюты; F2 - помощь"
     lgr.autoext label "КНП"
                 format "zzz"
                 validate(can-find(codfr where codfr.codfr = 'spnpl'
                 and codfr.code = string(lgr.autoext,'999')) and lgr.autoext <> 'msc'
                 ,'Неверное значение кода назначения платежа')
                 help "Введите КНП; F2 - помощь"
     lgr.tlev label "Тип кл"
                 format "z"
                 validate(lgr.tlev = '' or
                 (can-find(codfr where codfr.codfr = 'lgrsts'
                 and codfr.code = string(lgr.tlev)) and lgr.tlev <> 'msc')
                 ,'Неверное значение кода типа клиентов')
                 help "Введите код типа клиентов; F2 - помощь"
     lgr.feensf label "Схема"
                 format "z"
                 validate(can-find(codfr where codfr.codfr = 'dpschema'
                 and codfr.code = string(lgr.feensf,'9')) and lgr.feensf <> 'msc',
                 'Неверное значение схемы начисления %%')
                 help "Введите схему начисления %% по депозиту; F2 - помощь"
     v-comiss label "Ком"
              format "x(3)"
              help "1 - снимать комиссию за кросс-конвертацию, 0 - не снимать"
              validate (v-comiss = "0" or v-comiss = "1", "Неверное значение")
with centered row 4 7 down overlay title
    " Определение групп счетов срочных депозитов " frame lgr.

form lgr.prd label       "Минимальный срок      "
             format "           z9"
             help "Мминимальный срок депозита в месяцах"
             validate(lgr.prd > 0, "Должен быть > 0 and <= 99")
             skip
     lgr.dueday label    "Максимальный срок     "
             format "          z99"
             help "Максимальный срок депозита в месяцах; 0 - без ограничений"
             validate(lgr.prd >= 0, "Должен быть >= 0 and <= 99")
             skip
     lgr.tlimit[1] label "Минимальная сумма     " format "zz,zzz,zzz.99"
             help "Минимальная сумма депозита; 0 - без ограничений"
             skip
     lgr.tlimit[2] label "Дополнительные взносы " format "zz,zzz,zzz.99"
             help "Минимальная  сумма дополнительных взносов; 0 - не предусмотрены"
             skip
     lgr.tlimit[3] label "Макс. %  изъятия      " format "zz,zzz,zzz.99"
             help "Максимальный % по сумме изъятия; 0 - не предусмотрены"
with side-label row 15 column 1 title " Cроки и суммы " frame lgr1.

form lgr.pri label         "Код таблицы % ставок             "
             format "x(3)"
             validate(can-find(first pri where pri.pri begins "^" + lgr.pri and lgr.pri <> ' ')
                    , "Таблица с таким кодом не существует!")
             help "Введите код таблицы % ставок; F2 - help"
             skip
    lgr.intcal label       "Начисление                       "
             format " x(1)"
             help "Введите периодичность в месяцах, 0 - при открытии,D-ежедневно,N-не начислять"
             validate(lgr.intcal = "S" or lgr.intcal = "D" or lgr.intcal = "N"
                     , "Должно быть S, D или N")
             skip
     lgr.intpay label       "Выплата                          "
             format " x(1)"
             help "S-при открытии, M-ежемесячно,Q-ежеквартально,Y-ежегодно,F-по окончании"
             validate(lgr.intpay = "S" or lgr.intpay = "M" or lgr.intpay = "Q" or lgr.intpay = "Y" or lgr.intpay = "F"
                    , "Должно быть S, M, Q, Y или F")
             skip
     lgr.type label         "Капитализация                    " format " x(1)"
             help "M-ежемесячно,Q-ежеквартально,Y-ежегодно, N-не капитализировать"
             validate(lgr.type = "M" or lgr.type = "Q" or lgr.type = "Y" or lgr.type = "N" or lgr.type = ""
                    , "Должно быть D, M, Q, Y или N")
            skip
     lgr.prefix label       "Обновление таблицы % ставок      " format " x(1)"
             help "M-ежемесячно,Q-ежеквартально,Y-ежегодно,N-не обновлять"
             validate(lgr.prefix = "M" or lgr.prefix = "Q" or lgr.prefix = "Y" or lgr.prefix = "N" or lgr.prefix = ""
                    , "Должно быть M, Q, Y или N")
with side-label overlay row 15 column 41 title " Проценты " frame lgr2.




