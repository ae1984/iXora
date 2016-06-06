/* set_permissions.p
 * MODULE
        Обработка временных прав пользователей.
 * DESCRIPTION
        Проставляет и удаляет права пользователей.
 * RUN
        Из dayclose при закрытии дня
 * CALLER
        dayclose
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU   
        -
 * AUTHOR
        17.09.04 - suchkov
 * CHANGES
        01.08.06 Isakov A.(u00671) - 1) добавленно условие для выдачи и удаление прав.
                                     2) добавлен входной парамтр для выбора видов прав: выдача или удаление, либо и то и другое.
                                     3) добавлена обработка нового тип прав : "Премещение офицера между подразделениями".
*/
/* {mainhead.i} */
{global.i}
{funcpath.i}
{sysc.i}

/* Isakov A. - 01.08.06 ------------------------------------------------------------------- */
def var vdep like ppoint.depart.
def input parameter p-vid_permissions as int. 
/* Виды прав : 0 - выдача и удаление прав, 1 - только выдача прав, 2 - только удаление прав */

define variable v-path as character .
define variable per    as character .
define shared var s-target as date. 

/*define temp-table tempsec
    field who as  character 
    field whn as  date
    field bdat as date
    field edat as date
    field perm as character 
    field type as integer 
    field ofc  as character 
    field sts  as integer . */

find sysc where sysc.sysc = "LSFILE" no-lock no-error.
if avail sysc then v-path = sysc.chval.
              else v-path = "/data/log/tempsec.log".

/* Выдача прав */

if p-vid_permissions = 0 or p-vid_permissions = 1 then /* Isakov A. - 01.08.06 */
  do:
    for each tempsec where bdat = s-target no-lock .
        case tempsec.type:
    
            /* Права к пунктам меню (функция) */
            when 1 then do:
                find sec where sec.ofc = tempsec.ofc and sec.fname = tempsec.perm no-lock no-error.
                if not available sec then do:
                    create sec.
                    assign
                    sec.sts = 0
                    sec.fname = tempsec.perm 
                    sec.ofc = tempsec.ofc .
                end.
            end.
    
    
            /* Права к шаблонам */
            when 2 then do:
                find ujosec where ujosec.template = tempsec.perm no-error.
                if available ujosec then do:
                    if lookup (tempsec.ofc,ujosec.officers) > 0 then next.
                    else
                    ujosec.officers = ujosec.officers + "," + tempsec.ofc.
                end.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Шаблон " tempsec.perm " не найден!".
                    output close.
                end.
            end.
    
            /* Права к процесса платежной системы */
            when 3 then do:
                find pssec where pssec.proc = tempsec.perm no-error.
                if available pssec then do:
                    if lookup (tempsec.ofc,pssec.ofcs) > 0 then next.
                    else
                    pssec.ofcs = pssec.ofcs + "," + tempsec.ofc .
                end.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Процесс " tempsec.perm " не найден!".
                    output close.
                end.
            end.
    
            /* Права к пунктам верхнего меню */
            when 4 then do:
                find optitsec where optitsec.proc = tempsec.perm no-error.
                if available optitsec then do:
                    if lookup (tempsec.ofc,optitsec.ofcs) > 0 then next.
                    else
                    optitsec.ofcs = optitsec.ofcs + "," + tempsec.ofc .
                end.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Пункт " tempsec.perm " не найден!" . 
                    output close.
                end.
            end.
        
            /* Права к пунктам меню (путь) */
            when 5 then do:
                output to value(v-path) append.
                per = get-fname(tempsec.perm) .
                output close.
                find sec where sec.ofc = tempsec.ofc and sec.fname = per no-lock no-error.
                if not available sec then do:
                    create sec.
                    assign
                    sec.sts = 0
                    sec.fname = per
                    sec.ofc = tempsec.ofc .
                end.
            end.
    
            /* Пакеты */
            when 6 then do:
                find ofc where ofc.ofc = tempsec.ofc exclusive-lock no-error.
                if available ofc then ofc.expr[1] = ofc.expr[1] + "," + tempsec.perm .
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Офицер " tempsec.ofc " не найден!" . 
                    output close.
                end.
            end.
    
            /* Isakov A. - 01.08.06 */
            /* Премещение офицера между подразделениями */ 
            when 7 then 
              do:
                find ofc where ofc.ofc = tempsec.ofc exclusive-lock no-error.             
                ofc.titcd = tempsec.profitin.

                if tempsec.profitin <> tempsec.profitout then do: /* ведение истории смены профит-центров(ЦО) */
                  find ofcprofit where ofcprofit.ofc      = tempsec.ofc 
                                   and ofcprofit.profitcn = tempsec.profitin
                                   and ofcprofit.regdt    = s-target exclusive-lock no-error.
              
                  if not avail ofcprofit then 
                    do:
                      create ofcprofit.
                      assign ofcprofit.ofc      = tempsec.ofc
                             ofcprofit.profitcn = tempsec.profitin
                             ofcprofit.regdt    = s-target.
                    end.
                  
                  assign ofcprofit.tim = time
                         ofcprofit.who = tempsec.who.
                         
                end.
 
                if tempsec.depin <> tempsec.depout then do: /* ведение истории смены департамента(СПФ) */
                  find ofchis where ofchis.ofc   = tempsec.ofc 
                                and ofchis.regdt = s-target exclusive-lock no-error.
                  if available ofchis then do :
                    ofchis.point = 1.
                    ofchis.dep = tempsec.depin.
                    end.
                  else do :
                    create ofchis.
                    assign ofchis.ofc   = tempsec.ofc
                           ofchis.point = 1
                           ofchis.dep   = tempsec.depin.
                           ofchis.regdt = s-target.
                  end.
              
                  ofc.regno = 1000 + tempsec.depin.
                end.

                /* записать в список сотрудников */
                do:
                  find ofc-tn where ofc-tn.ofc = tempsec.ofc exclusive-lock no-error.
                  if avail ofc-tn then do:
                    ofc-tn.profitcn = tempsec.profitin.
                  end.
                end.
              end.
              
        end case.
    end. /* end for each */
  end. /* end do: */
    
/* Удаление прав */

if p-vid_permissions = 0 or p-vid_permissions = 2 then /* Isakov A. - 01.08.06 */
  do:
    for each tempsec where edat = s-target no-lock .
        case tempsec.type:
    
            /* Права к пунктам меню (функция) */
            when 1 then do:
                find sec where sec.ofc = tempsec.ofc and sec.fname = tempsec.perm exclusive-lock no-error.
                if available sec then delete sec.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Функция " tempsec.perm " не найдена!".
                    output close.
                end.
            end.
    
    
            /* Права к шаблонам */
            when 2 then do:
                find ujosec where ujosec.template = tempsec.perm no-error.
                if available ujosec then do:
                    if lookup (tempsec.ofc,ujosec.officers) > 0 then do:
                        if index(tempsec.ofc,ujosec.officers) = 1 then ujosec.officers = replace(ujosec.officers, tempsec.ofc, ""). 
                                                                  else ujosec.officers = replace(ujosec.officers, "," + tempsec.ofc, "").
                    end.
                    else next.
                end.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Шаблон " tempsec.perm " не найден!".
                    output close.
                end.
            end.
    
            /* Права к процесса платежной системы */
            when 3 then do:
                find pssec where pssec.proc = tempsec.perm no-error.
                if available pssec then do:
                    if lookup (tempsec.ofc,pssec.ofcs) = 0 then next.
                    else do:
                        if index(tempsec.ofc,pssec.ofcs) = 1 then pssec.ofcs = replace(pssec.ofcs, tempsec.ofc, ""). 
                                                             else pssec.ofcs = replace(pssec.ofcs, "," + tempsec.ofc, "").
                    end.
                end.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Процесс " tempsec.perm " не найден!".
                    output close.
                end.
            end.
    
            /* Права к пунктам верхнего меню */
            when 4 then do:
                find optitsec where optitsec.proc = tempsec.perm no-error.
                if available optitsec then do:
                    if lookup (tempsec.ofc,optitsec.ofcs) = 0 then next.
                    else do:
                        if index(tempsec.ofc,optitsec.ofcs) = 1 then optitsec.ofcs = replace(optitsec.ofcs, tempsec.ofc, ""). 
                                                                else optitsec.ofcs = replace(optitsec.ofcs, "," + tempsec.ofc, "").
                    end.
                end.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Пункт " tempsec.perm " не найден!" . 
                    output close.
                end.
            end.
        
            /* Права к пунктам меню (путь) */
            when 5 then do:
                output to value(v-path) append.
                per = get-fname(tempsec.perm) .
                output close.
                find sec where sec.ofc = tempsec.ofc and sec.fname = per no-error.
                if available sec then delete sec.
            end.
    
            /* Пакеты */
            when 6 then do:
                find ofc where ofc.ofc = tempsec.ofc no-error.
                if available ofc then do:
                    if index(ofc.expr[1],tempsec.perm) = 1 then ofc.expr[1] = replace(ofc.expr[1], tempsec.perm, ""). 
                                                           else ofc.expr[1] = replace(ofc.expr[1], "," + tempsec.perm, "").
                end.
                else do:
                    output to value(v-path) append.
                    put g-today " - " string(time,"HH:MM:SS") " - Внимание! Офицер " tempsec.ofc " не найден!" . 
                    output close.
                end.
            end.
            
            /* Isakov A. - 01.08.06 */
            /* Премещение офицера между подразделениями. 
               Если дата окончания временного перемещения есть, то 
               будем переводить обратно в то под-ние в котором был до перевода
            */
            when 7 then 
              do:
                find ofc where ofc.ofc = tempsec.ofc exclusive-lock no-error.             
                ofc.titcd = tempsec.profitout.

                if tempsec.profitout <> tempsec.profitin then do: /* ведение истории смены профит-центров(ЦО) */
                  find ofcprofit where ofcprofit.ofc      = tempsec.ofc 
                                   and ofcprofit.profitcn = tempsec.profitout
                                   and ofcprofit.regdt    = s-target exclusive-lock no-error.
              
                  if not avail ofcprofit then 
                    do:
                      create ofcprofit.
                      assign ofcprofit.ofc      = tempsec.ofc
                             ofcprofit.profitcn = tempsec.profitout
                             ofcprofit.regdt    = s-target.
                    end.
                  
                    assign ofcprofit.tim = time
                           ofcprofit.who = tempsec.who.
                end.
 
                if tempsec.depout <> tempsec.depin then do: /* ведение истории смены департамента(СПФ) */
                  find ofchis where ofchis.ofc   = tempsec.ofc 
                                and ofchis.regdt = s-target exclusive-lock no-error.
                  if available ofchis then do :
                    ofchis.point = 1.
                    ofchis.dep = tempsec.depout.
                    end.
                  else do :
                    create ofchis.
                    assign ofchis.ofc   = tempsec.ofc
                           ofchis.point = 1
                           ofchis.dep   = tempsec.depout.
                           ofchis.regdt = s-target.
                  end.
              
                  ofc.regno = 1000 + tempsec.depout.
                end.

                /* записать в список сотрудников */
                do:
                  find ofc-tn where ofc-tn.ofc = tempsec.ofc exclusive-lock no-error.
                  if avail ofc-tn then do:
                    ofc-tn.profitcn = tempsec.profitout.
                  end.
                end.

              end.
    
        end case.
    end. /* end for each */
  end. /* end do: */
