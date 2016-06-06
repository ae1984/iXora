/* tdainttab.f
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
 * CHANGES
*/

def var vdown as inte initial 6.
form gpri.gpri label "Код " format "x(3)"
     gpri.name label "Описание   " format "x(57)"
     gpri.itype label "Тип " format "9"
                help "Введите тип процентной ставки: 1-фиксированная, 2-ступенчатая"
                validate(gpri.itype = 1 or gpri.itype = 2, "1-фиксированная, 2-ступенчатая")
     gpri.rate label "Fixed Rate"
     help "Введите % ставку"
     with no-label row 3 5 down centered overlay 
          title "Таблицы % ставок срочных депозитов" frame ss3.
form head11 format "x(14)"  
     head12 format "x(14)"
     head13 format "x(14)"
     head14 format "x(14)"
     head15 format "x(14)"
     with no-label no-box column 6 row 12 overlay frame ss2.
form head1 format "x(4)"
     gpri.tlimit[1] 
      validate(gpri.tlimit[1] <= gpri.tlimit[2],"Должно быть <= чем Ступень  2") 
      help "Введите ступень 1" format "zzz,zzz,zzz.99" 
     gpri.tlimit[2] 
      validate(gpri.tlimit[1] <= gpri.tlimit[2] and gpri.tlimit[2] <= gpri.tlimit[3],"Должно быть >= чем Ступень 1 и <= чем Ступень 3") 
      help "Введите ступень 2" format "zzz,zzz,zzz.99" 
     gpri.tlimit[3] 
      validate(gpri.tlimit[2] <= gpri.tlimit[3] and gpri.tlimit[3] <= gpri.tlimit[4],"Должно быть >= чем Ступень 2 и <= чем Ступень 4") 
      help "Введите ступень 3" format "zzz,zzz,zzz.99" 
     gpri.tlimit[4] 
      validate(gpri.tlimit[3] <= gpri.tlimit[4] and gpri.tlimit[4]
<= gpri.tlimit[5],"Должно быть  >= чем Ступень 3 и <= чем Ступень 5") 
      help "Введите ступень 4" format "zzz,zzz,zzz.99" 
     gpri.tlimit[5] 
       format "zzz,zzz,zzz.99" 
     with no-label no-box column 1 row 13 overlay frame ss1.
form vrate.vterm help "Введите срок в месяцах" format "zz" at 2
     validate(vrate.vterm > 0 and vrate.vterm <= 99, "Should be from 1 to99")
     vrate.rate[1] help "Введите % ставку" format "zz.9999" at 12 
     vrate.rate[2] help "Введите % ставку" format "zz.9999" at 27
     vrate.rate[3] help "Введите % ставку" format "zz.9999" at 42
     vrate.rate[4] help "Введите % ставку" format "zz.9999" at 57
     vrate.rate[5] help "Введите % ставку" format "zz.9999" at 72
     with no-label vdown  down column 1 row 14 overlay frame ss.
