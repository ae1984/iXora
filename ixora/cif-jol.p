/* cif-jol.p
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
        21.12.04 dpuchkov добавил адрес электронной почты
        24.06.08 alex добавил БИН/ИИН
*/

/* checked */
/* cif-joi.p */

{global.i}

{
head2e.i
&var = "def shared var s-cif like cif.cif.
        def var  v-tax1 as char format ""x(8)"".
        def var  v-tax2 as char format ""x(25)"".
        def var v-jss as character extent 10.
        def var v-dt  as date.
        def variable i as integer.
        def var rin as char.
        def var dd as integer.
        def var mm as integer.
        def var gg as integer.
        def var v-rnn as log. "
        
&start = "find cif where cif.cif = s-cif.
          find last cif-mail where cif-mail.cif=cif.cif no-lock no-error.
          if not avail cif-mail then do:
             create cif-mail.
             cif-mail.cif = cif.cif.
          end.
 v-tax1=trim(cif.ssn) no-error.
 if cif.jss ne """" then do:
   find codfr where codfr.codfr = ""rnnsp"" and
        codfr.code = substr(cif.jss,4,1) use-index cdco_idx no-lock no-error.
        if avail codfr then  v-tax2 = codfr.name[1].
 end.
 else v-tax2="" "".
 v-jss[1] = cif.jel.
 do i = 2 to 10:
    if index(v-jss[i - 1],'&') > 0
    then do:
         v-jss[i] = substring(v-jss[i - 1],index(v-jss[i - 1],'&') + 1).
         v-jss[i - 1] =
             substring(v-jss[i - 1],1,index(v-jss[i - 1],'&') - 1).
    end.
    else v-jss[i] = ''.
 end.
 if index(v-jss[10],'&') > 0
 then v-jss[10] = substring(v-jss[10],1,index(v-jss[10],'&') - 1).
 rin = v-jss[1].
 i = index(rin,'/').
 if i = 0
 then v-dt = ?.
 else do:
      dd = integer(trim(substring(rin, 1, i - 1))).
      rin = substring(rin, i + 1).
      i = index(rin, '/').
      mm = integer(trim(substring(rin, 1, i - 1))).
      rin = substring(rin, i + 1).
      gg = integer(trim(substring(rin, 1))).
      v-dt = date(mm, dd, gg).
 end."
&form = " cif.bin   format 'x(12)'        label 'БИН/ИИН.......'
          cif.jss   format '999999999999' label 'РНН...........'
          v-tax2    format 'x(25)'        label 'Район.........'
          v-tax1    format 'x(8)'         label 'ОКПО..........'
          v-dt      format '99/99/9999'   label 'Дата..........'
          v-jss[2]  format 'x(30)'        label 'Примечание....'
          v-jss[3]  format 'x(30)'        label ' .............'
          v-jss[4]  format 'x(30)'        label ' .............'
          v-jss[5]  format 'x(30)'        label ' .............'
          v-jss[6]  format 'x(30)'        label ' .............'
          v-jss[7]  format 'x(30)'        label ' .............'
	  cif-mail.mail format 'x(30)'        label 'E-mail........'
"

&fldupdt = " "
&frame = "1 col centered row 3 overlay title ""Регистрационные данные"""
&vseleform = "1 col no-label col 67 overlay "
&flddisp = " cif.bin cif.jss v-tax1 v-tax2 v-dt v-jss[2] v-jss[3] v-jss[4] v-jss[5] v-jss[6] v-jss[7] cif-mail.mail "
&file = "cif"
&index = "cif"
/*
&posupdt = " do on error undo , retry :
               update cif.jss with frame cif.
               if cif.jss ne """" then do :
                   run rnnchk( input cif.jss,output v-rnn).
                 if v-rnn then do :
                   message ""Введите РНН верно ! "". pause.
                   undo, retry.
                 end.  
                 find codfr where codfr.codfr = ""rnnsp"" and 
                   codfr.code = substr(cif.jss,4,1) use-index cdco_idx no-lock
                                no-error.
                 if avail codfr then do :
                   v-tax2 = codfr.name[1].
                   display v-tax2 with frame cif.
                 end.
                 
               end.  
             end.     
update v-tax1 v-dt v-jss[2] v-jss[3] v-jss[4] v-jss[5] v-jss[6] 
v-jss[7] with frame cif."
cif.jel = ''. if v-dt = ? then v-jss[1] = ''. else
 v-jss[1] = string(v-dt,'99/99/9999').
 do i = 1 to 10:
    cif.jel = cif.jel + v-jss[i] + '&'.
 end.
 cif.ssn = v-tax1 .                                
 "
*/
&prg1  = "x"
&prg2  = "x"
&prg3  = "x"
&prg4  = "x"
&prg5  = "x"
&prg6  = "x"
&prg7  = "x"
&prg8  = "x"
&prg9  = "x"
&prg10 = "x"
}
/*--------------------------------------------------------------------------
  #3.
      1.izmai‡a  - lauks jss tiek izmantots re¦istr–cijas apliecЁbas numura
                   uzglab–Ѕanai
      2.izmai‡a  - lauks jel tiek izmantots form– a1&a2&a3&...a10&, kur
        a1       - re¦istr–cijas datums
        a2 - a7  - piezЁmes
        a8 - a10 - var izmantot citiem nol­kiem
----------------------------------------------------------------------------*/
