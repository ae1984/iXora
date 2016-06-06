/* ch_close.p
 * MODULE
        Операционный департамент - Закрытие счета по истечении 180 дней
 * DESCRIPTION
        Закрытие счета по истечении 180 дней
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
        30/06/2006 u00600
 * CHANGES
        28/07/2006 u00600 - счета, по которым не было движения
        01/08/2006 u00600 - update sub-cod если счет до этого однажды был закрыт
        07/08/2006 u00600 - берем в jl 1-й уровень и (g-today - aaa.regdt) > 180
        08/08/2006 u00600 - берем в jl счет ГК по счету в ааа
        13/08/2009 galina - добавила запрос согласия и запись в историю

*/

def var out as char no-undo.
def temp-table t-aaa no-undo
    field cif  like cif.cif
    field name like cif.name
    field aaa  like aaa.aaa
    field sta  like aaa.sta.

{global.i}

def var v-ans as logical.
message skip " Будут закрыты все текущие счета физ.лиц,~n по которым отсутствуют движения более 180 дней. Продолжить ?"
skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-ans.
if not v-ans then return.

message ' Идет закрытие счетов ...'.
out = "chet-close" + string(TIME) + ".txt".

for each cif no-lock use-index cif .
  if cif.type <> "P" then next.

  for  each aaa where aaa.cif = cif.cif and aaa.sta ne 'C' and (g-today - aaa.regdt) > 180 no-lock use-index aaa-idx1 .
    if (aaa.dr[1] - aaa.cr[1]) = 0 then do:

      for each lgr where lgr.lgr = aaa.lgr and lgr.led = 'sav' no-lock. /*если счет не депозитный*/

        find first lon where lon.aaa = aaa.aaa no-lock no-error.  /*если счет открыт по кредиту, то не берем*/
        if not avail lon then do:

          find last jl where jl.acc = aaa.aaa and jl.gl = aaa.gl no-lock no-error. 
            if avail jl then do: 
             if (g-today  - jl.jdt) > 180 then do:

              create t-aaa.
              assign t-aaa.cif  = cif.cif
                     t-aaa.name = cif.name
                     t-aaa.aaa  = aaa.aaa
                     t-aaa.sta  = aaa.sta.

            end.  /*(g-today  - jl.jdt) > 180*/
            end.  /*avail jl */
            else do:  /*not avail jl*/

              create t-aaa.
              assign t-aaa.cif  = cif.cif
                     t-aaa.name = cif.name
                     t-aaa.aaa  = aaa.aaa
                     t-aaa.sta  = aaa.sta.
            end.  /*else do*/
  
        end. /*not avail lon*/
      end. /*for each lgr*/
    end. /*(aaa.dr[1] - aaa.cr[1]) = 0*/
    
  end. /*for each aaa*/
end.  /*for each cif*/

/*def buffer b-bxcif for bxcif.*/

OUTPUT TO chet-close.txt.
  put 
  "ФИО     "
  "Код                                       "
  "Текущий счет"
  skip.

  for each t-aaa . 
    find first aaa where aaa.aaa = t-aaa.aaa exclusive-lock no-error.
      if avail aaa then do:

        find sub-cod where sub = 'cif' and sub-cod.acc = t-aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
            
           if not avail sub-cod then do:
                create sub-cod.
                sub-cod.sub = 'cif'.
                sub-cod.acc = t-aaa.aaa.
                sub-cod.d-cod = 'clsa'.
                sub-cod.ccode = '02'.
                sub-cod.rdt = g-today.
            end.
            else do:
            find current sub-cod exclusive-lock .
            update sub-cod.rdt = g-today.
                   sub-cod.ccode = '02'.         
            find current sub-cod no-lock .
            end.
            
            create hissc.
                   hissc.sub = 'cif'.
                   hissc.acc = t-aaa.aaa.
                   hissc.d-cod = 'clsa'.
                   hissc.ccode = '02'.
                   hissc.rdt = g-today.
                   hissc.who = g-ofc.
                   hissc.tim = time.                
            
            aaa.sta = 'C'.
            release aaa.
      end. 

    /*обнуление задолженности (удаление) - отменяется !!!!*/
    /*for each bxcif where bxcif.cif = t-aaa.cif no-lock.*/
    /*find first bxcif where bxcif.cif = t-aaa.cif no-lock no-error. 
    if avail bxcif then do:*/ /*если есть задолженность*/

      /*find first aaa where aaa.cif = bxcif.cif and aaa.sta ne 'C' no-lock no-error.
      if not avail aaa then do:*/  /*если нет ни одного открытого счета, то удаляем задолженность*/
        /*for each b-bxcif where b-bxcif.cif = aaa.cif exclusive-lock.
          delete b-bxcif. 
        end.
      end.

    end.*/

    put
    t-aaa.cif format "x(6)"  "  "
    t-aaa.name format "x(40)"  "  "
    t-aaa.aaa format "x(10)" "  "
    skip.
  end.

OUTPUT CLOSE.

unix silent value('un-win chet-close.txt ' + out).

run mail("saitahunova@elexnet.kz,babiy@elexnet.kz,sinyak@elexnet.kz,juli@elexnet.kz,tulpin@elexnet.kz,adambekova@elexnet.kz,rush@elexnet.kz,azor@elexnet.kz","abpk@elexnet.kz", "account_closing", "", "1", "", out).

unix silent rm -f chet-close.txt.
unix silent value("rm -f " + out).
