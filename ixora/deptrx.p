/* sklad.p
 * MODULE
        Автоматизация проводки по страхованию        
 * DESCRIPTION
        Автоматизация проводки по страхованию        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.8
 * AUTHOR
        03/12/2001 sasco
 * CHANGES
        21/09/2003 sasco - обработка списка списания с Г/К и АРП счетами 
                           генерируются две проводки в зависимости от списка
                           + обработка шаблона VNB0055
	26/05/2004 valery - операционный ордер будет печататься без вопроса
        12/10/04 sasco - добавил вывод subamt, subcost в форме текущего склада и остатков на дату
                       - Раскомментировал удаление проводок (техзадание # 1162)
        09.08.05 nataly - добавила счет ГК в таб-цу sklada + возможность редактирование группы и товара
        30.10.05 nataly  - изменила редактирование комментария
        23/01/06 nataly добавила признак архивности справочника 
        30/03/06 nataly добавила release .
*/


{deptrx.f}
{global.i}
{yes-no.i}

def stream rpt.
def new shared var v-date as date.
def var v-code as char.

def var v-gl  like gl.gl init "575200".
def var v-arp as char.
def var v-crc like crc.crc.
def var v-rem as char.
def var v-dep as char.
def var v-sum as decimal.
ON HELP OF temptrx.dep  IN FRAME income do:  run help-dep("000").
                                        temptrx.dep:screen-value = return-value.
                                        temptrx.dep = return-value.
                                    end.

ON endkey OF FRAME income hide frame income.

/*DEFINE SUB-MENU subadd
      MENU-ITEM skadd  LABEL "Приход".
  */

DEFINE SUB-MENU subremp     /*Приход*/
      MENU-ITEM skrema LABEL "Ввод реквизитов транзакции"
      MENU-ITEM skremap LABEL "Формирование списка"
      MENU-ITEM skrems  LABEL "Предварительный просмотр транзакции"
      MENU-ITEM skremp  LABEL "Проводка"
      RULE
      MENU-ITEM skremnp LABEL "Очистить список".

/*DEFINE SUB-MENU subrem
      MENU-ITEM skrema LABEL "Изменение списка"
      MENU-ITEM skrem  LABEL "Проводка"
      RULE
      MENU-ITEM skremn LABEL "Очистить список".
  */

DEFINE SUB-MENU subquit
      MENU-ITEM skquit LABEL "Выход".

DEFINE SUB-MENU subopt
      MENU-ITEM sktrxdl LABEL "Удаление проводок". 


DEFINE MENU mbar MENUBAR
      SUB-MENU subremp  LABEL "Ввод данных"
      SUB-MENU subopt  LABEL "Настройки"
      SUB-MENU subquit LABEL "Выход".

ON CHOOSE OF MENU-ITEM sktrxdl  /* TRX STORNO */    
    do:
        run sklstor.
        hide all.
    end.


/*ПРИХОД*/
ON CHOOSE OF MENU-ITEM skrema /* реквизиты транзакции */
    do:
        run r-sklada.
        hide all.
    end.    

/*ПРИХОД*/
ON CHOOSE OF MENU-ITEM skremap /* формирование списка  - ПРИХОД*/
    do:
        run r-skladap.
        hide all.
    end.    

ON CHOOSE OF MENU-ITEM skremnp /* очистить список  - ПРИХОД*/
    do:
        run r-skladnp.
        hide all.
    end.    

ON CHOOSE OF MENU-ITEM skremp /* транзакция - ПРИХОД */
    do:
        run r-skladp. 
        hide frame outgo.
     end.

ON CHOOSE OF MENU-ITEM skrems /* Сверка остатков  - ПРИХОД */
    do:
        run r-sklads. 
        hide frame outgo.
     end.
        

on "value-changed" of browse bp
do:
   st_amt = 0.
   st_sum = 0.0.
/*   if avail wsk then do:
      for each st_buf where st_buf.pid = skladt.pid and st_buf.sid = skladt.sid no-lock.
          st_amt = st_amt + st_buf.amt.
          st_sum = st_sum + (st_buf.amt * st_buf.cost).
      end.
   end.
   displ st_amt st_sum with frame st.*/
end.

/* --------------------  добавление Департамента  ---------- */
on "insert" of browse bp
do:
     run n-sklad.
   hide all.

   totamt = 0.
    for each temptrx.
               totamt = totamt + temptrx.sum.
    end.
    displ totamt  with frame ftp no-label.
 
   close query qp.
   open query qp for each temptrx by temptrx.dep .
   if can-find (first temptrx) then browse bp:refresh().
   apply "value-changed" to browse bp.
end.

/* --------------------  редактирование Департамента  ---------- */
on "return" of browse bp
do:
   totamt = 0.
   find current temptrx no-error.
   if avail temptrx then do:
    find first wskitem no-lock no-error.
    if avail wskitem  then do:   
      temptrx.gl = wskitem.gl.  
      temptrx.arp = wskitem.arp.
      temptrx.crc = wskitem.crc.
      temptrx.rem = wskitem.rem.
    end.
    else do:
      temptrx.gl = 0.
      temptrx.arp = "".
      temptrx.rem = "".
    end.
    update temptrx.dep  with frame income.
     v-dep = temptrx.dep.
     find first codfr where codfr.codfr = 'sdep' and codfr.code =  v-dep  no-lock no-error.
     if avail codfr then  temptrx.des = codfr.name[1]. else temptrx.des = "". 
     displ temptrx.des with frame income.
     update  temptrx.sum with frame income.
    end.
    else do: 
       message 'Список пуст!'. 
       pause 3. 
     end. 
   hide frame income.

    for each temptrx.
               totamt = totamt + temptrx.sum.
     /*message temptrx.sum temptrx.dep.*/
    end.
    displ totamt  with frame ftp no-label.

   close query qp.
   open query qp for each temptrx by temptrx.dep .
   if can-find (first temptrx) then browse bp:refresh().
   apply "value-changed" to browse bp.
end.
/* --------------------------------  удаление департамента из списка */
on "clear" of browse bp
do:
    yesno = yes-no("Удаление из списка", "Вы уверены?").
    if yesno then
    do:
        v-dep = temptrx.dep.
        v-sum = temptrx.sum.
        find first temptrx where temptrx.dep = v-dep and temptrx.sum = v-sum   exclusive-lock.
        delete temptrx.
        release temptrx.


   totamt = 0.
        for each temptrx.
               totamt = totamt + temptrx.sum.
        end.
        displ totamt  with frame ftp no-label.
        close query qp.
        open query qp for each temptrx by temptrx.dep .

        if can-find(first temptrx no-lock) then
        browse bp:refresh().
        apply "value-changed" to browse bp.
    end.
end.

ASSIGN CURRENT-WINDOW:MENUBAR = MENU mbar:HANDLE.
WAIT-FOR CHOOSE OF MENU-ITEM skquit.               /* выход */
    

/*for each temptrx: delete temptrx. end.*/


/*-------------------------    приход     -------------*/
procedure n-sklad.
   create temptrx.
   temptrx.who = g-ofc.
   temptrx.whn = g-today.
    find first wskitem no-lock no-error.
    if avail wskitem  then do:   
      temptrx.gl = wskitem.gl.  
      temptrx.arp = wskitem.arp.
      temptrx.crc = wskitem.crc.
      temptrx.rem = wskitem.rem.
    end.
    else do:
      temptrx.gl = 0.
      temptrx.arp = "".
      temptrx.rem = "".
    end.
   displ temptrx.who temptrx.whn temptrx.gl with frame income.
   disable temptrx.who temptrx.whn /* byes2*/ with frame income.
   update temptrx.dep with frame income.
   v-dep = temptrx.dep.
    find first codfr where codfr.codfr = 'sdep' and codfr.code =  v-dep  no-lock no-error.
   if avail codfr then  temptrx.des = codfr.name[1]. else temptrx.des = "". 
   displ temptrx.des with frame income.
   update temptrx.sum with frame income.
    
end procedure.


procedure prichod.

def var pri as integer.
def var pra as integer.
def var prc as decimal.
def var sum as decimal init 0.
def var v-code as char.
def var v-dep as char.
def var v-gl like gl.gl.
def buffer bjl for jl. 
def var v-code1 as char init '3080502'.

 s-jh = 0.
   displ "Создание проводки..." with centered row 10 frame fff.

 find first temptrx no-error.
if not avail temptrx then do:
   message 'Список пуст ! Проводка не создалась !'.
   hide frame fff.
   return.
 end.
for each temptrx.
 v-param = string(temptrx.sum) +  v-del + string(temptrx.crc) +  v-del +  string(temptrx.gl) + v-del + string(temptrx.arp) +  v-del +  temptrx.rem   . 
 v-doc = "VNB0002".
 do transaction:       
      v-gl = temptrx.gl.
     {depcods1.i}
     RUN trxgen (v-doc, v-del, v-param, "", "", output rcode, output rdes,
                    input-output s-jh).
     {depcods2.i}
         IF rcode <> 0 then
                    do:
                        message rcode rdes.
                        pause 50.
                        return.
                   end.
    if string(temptrx.gl) begins '5' then 
    do:
       find last bjl where bjl.jh = s-jh and  bjl.gl = temptrx.gl and bjl.dam = temptrx.sum no-lock no-error.
       find last trxcods where trxcods.trxh = s-jh and trxcods.trxln = bjl.ln and  trxcods.codfr = 'cods' no-error. 
       if not avail  trxcods then do:  
                       create trxcods. 
                        assign
                        trxcods.trxh  = bjl.jh
                        trxcods.trxln = bjl.ln
                        trxcods.codfr = 'cods'.
                    end.

      find first cods where cods.gl =  temptrx.gl and cods.arc = no and cods.code = v-code1  no-lock no-error.
       if not avail cods then do:
              v-code = "0000000".   v-dep = "000".
        end.
        else do:
              v-code = cods.code.   v-dep = temptrx.dep. 
        end.
     trxcods.code = v-code + v-dep.
     release trxcods.
     release cods.
    end.
 end.
end.

         def var colorders as integer init 1.
         def var i as integer.
         
    if s-jh <> 0 then do:
     UPDATE colorders label "Введите количество ордеров"
         with centered row 10 frame fcolord.
         HIDE FRAME fcolord.
         
         DISPL "Печать операционного ордера..." with centered row 10 frame fff.
         DO i = 1 to colorders:
            RUN vou_bank(1). /*параметр "1" означает что операционный ордер печатается без вопросов*/
            pause 0.
         END.
        
   hide frame fff. pause 0.
 end.
end procedure.

/*---------------------------   удаление списка - ПРИХОД ----------------*/
procedure r-skladnp.
    yesno = yes-no("Новый список","Внимание! Текущий список будет удален").
    if yesno = true then
    yesno = yes-no("","Вы уверены").
    if yesno = true then
       do:
          for each temptrx:
          delete temptrx.
          end.
       end.
end procedure.

/*---------------------------   реквизиты транзакции- ПРИХОД -------------*/
procedure r-sklada.
    find first wskitem no-error.
    if not avail wskitem then do: message 'no wskitem!'. create wskitem. end.
    find first temptrx no-lock no-error.
    if avail temptrx then do: 
          wskitem.arp  = temptrx.arp.
          wskitem.gl  = temptrx.gl.
          wskitem.crc  = temptrx.crc.
          wskitem.rem  = temptrx.rem.
    end. 

    update wskitem.arp 
           wskitem.gl 
           wskitem.crc 
           wskitem.rem with frame tmp.

    find first temptrx  no-error.
   if avail temptrx then do: 
    for each temptrx.
     assign 
            temptrx.rem = wskitem.rem.
    end.
   end.
   release temptrx.
end procedure.

/*---------------------------   редакция списка - ПРИХОД -------------*/
procedure r-skladap.
    open query qp for each temptrx by temptrx.dep .
    enable all with frame ftp.

    for each temptrx.
               totamt = totamt + temptrx.sum.
    end.
    displ totamt  with frame ftp no-label.
    apply "value-changed" to browse bp.
    wait-for window-close of frame ftp focus browse bp.
    release skladp.

end procedure.

/*---------------------------   сверка остатков - ПРИХОД   ----------------*/
procedure r-sklads.
   run sverka.
end procedure.

/*---------------------------   ТРАНЗАКЦИЯ - ПРИХОД   ----------------*/
procedure r-skladp.
   run prichod.
end procedure.


procedure sverka.
def var sumcol as integer.

 output stream rpt to trx.img.
  put stream rpt unformatted  '             СВЕРКА РЕКВИЗИТОВ И СУММ ПРОВОДКИ ПО СТРАХОВАНИЮ ' skip.
   put stream rpt unformatted fill('-',97) format "x(97)" skip.
  put stream rpt unformatted '|Департамент|    Наименование департамента      |   ARP   |  GL  |    Сумма       |' skip.
   put stream rpt unformatted fill('-',97) format "x(97)" skip.

for each temptrx break by temptrx.gl by temptrx.arp. 
   accum temptrx.sum (total by temptrx.arp).
   accum temptrx.sum (total by temptrx.gl).
  put stream rpt unformatted '|   ' temptrx.dep   format 'x(5)'  '   |'  temptrx.des  format 'x(34)'    ' |' temptrx.arp  format 'x(9)' '|'  temptrx.gl format 'zzzzz9'  '|' temptrx.sum format 'z,zzz,zzz,zz9.99' '|' skip.

  if last-of(temptrx.arp) then do:
   put stream rpt unformatted fill('-',97) format "x(97)" skip.
   put stream rpt unformatted  space(40) 'ИТОГО ПО ARP ' temptrx.arp  ACCUMulate total  by  temptrx.arp temptrx.sum format 'z,zzz,zzz,zzz,zz9.99' skip.   
  end. 

  if last-of(temptrx.gl) then do:
   put stream rpt unformatted fill('-',97) format "x(97)" skip.
   put stream rpt unformatted  space(40) 'ИТОГО ПО ГК ' temptrx.gl  space(4) ACCUMulate total  by  temptrx.gl temptrx.sum format 'z,zzz,zzz,zzz,zz9.99' skip(2).   
  end. 

end.
   put stream rpt unformatted fill('-',97) format "x(97)" skip.
 
output stream rpt close .
 run menu-prt('trx.img').
end procedure.