/* gcvpstat.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Поверка подлежащих к оплате услуг по выдаче информации о поступлении и движении средств вкладчика ГЦВП
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        /pragma/bin/gcvpstat - скрипт осуществляющий разборку файлов запросов-ответов
 * MENU
        4.14.7
 * AUTHOR
        08/01/04 isaev
 * CHANGES
        03.08.05 marinav  - данные берутся из архива /gcvp/год/месяц/

 */

{global.i}
{sysc.i}


def var t_yr as integer   label "      Выберите год" format ">>>9" initial 2004.
def var t_mn as integer   label "             месяц" format "99" .
def var t_verb as logical label "Показать подробную информацию?" initial yes.

define frame fr_gc skip 
             t_yr skip
             t_mn skip(1) 
             t_verb skip
             with row 10 side-labels centered title "Ответы из ГЦВП".
view frame fr_gc.

update t_yr validate(t_yr >= 2000 and t_yr <= 2030, "некорректный ввод")
       t_mn validate(t_mn >= 1 and t_mn <= 12, "некорректный ввод")
       t_verb
       with frame fr_gc.

hide frame fr_gc.

def var gc_dir as char.
gc_dir = get-sysc-cha("pkgcvi").


gc_dir = gc_dir + string(t_yr) + "/" + string(t_mn, '99') + "/".

def var file as char.
file = "gcvpstat.txt".

def var cmd_str as char.



assign cmd_str = "gcvpstat --dir=" + gc_dir +
                 " --year=" + string(t_yr) +
                 " --month=" + string(t_mn) + 
                 (if t_verb then " --verbose" else "") + 
                 ">" + file.

unix value(cmd_str).
run menu-prt(file).
unix value("rm -f " + file);
ile).
unix value("rm -f " + file);
