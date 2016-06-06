/* amt_level.i
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

/***  amt_level.i  **/




on value-changed of browse b_bal do:
    find trxsublv where trxsublv.subled eq Psub and trxsublv.level eq 
        ttleve.t_lev no-lock.                             
    find gl where gl.gl eq ttleve.t_glr no-lock.
    display trxsublv.des gl.gl gl.des with frame f_level.
end.

    
find {1} where {1}.{1} eq {2} no-lock no-error.
if not available {1} then do:
    message substitute ("&1 - Cчет &2 отсутствует", Psub, Pacc).
    return.
end.
                                          
find first trxbal where trxbal.subled eq {3} and trxbal.acc eq Pacc 
                                                        no-lock no-error.
if not available trxbal then do:
    message substitute ("&1 - Информация об остатках на счете &2 отсутствует",
        Psub, Pacc).
    return.    
end.

message "F4 - выход".
                                       
for each trxbal where trxbal.subled eq {3} and trxbal.acc eq Pacc no-lock:
    find trxlevgl where trxlevgl.gl eq {1}.gl and trxlevgl.subled eq Psub and
        trxlevgl.level eq trxbal.level no-lock.
    find gl where gl.gl eq trxlevgl.glr no-lock.    
    find crc where crc.crc eq trxbal.crc no-lock.
        
    create ttleve.
    ttleve.t_dam = trxbal.dam.
    ttleve.t_cam = trxbal.cam.
    ttleve.t_crc = crc.code.
    ttleve.t_lev = trxbal.level.
    ttleve.t_glr = trxlevgl.glr.
    if gl.type eq "A" or gl.type eq "E" then 
         ttleve.t_amt = trxbal.dam - trxbal.cam.
    else ttleve.t_amt = trxbal.cam - trxbal.dam.
    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
    and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
    if available sub-cod and sub-cod.ccode eq "01" then 
    ttleve.t_amt = - ttleve.t_amt.
end.


find crc where crc.crc eq {1}.crc no-lock no-error.
find gl where gl.gl eq {1}.gl no-lock.
display Pacc crc.crc crc.des gl.gl gl.des with frame f_account.

open query q_bal for each ttleve. 
enable all with frame f_bal.
apply "value-changed" to browse b_bal.


