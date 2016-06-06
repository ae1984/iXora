/* pkrateq.p
 * MODULE
        Потребкредит
 * DESCRIPTION
        Изменение ставки кредита
 * RUN
        верхнее меню "ИзмСтав"
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        3.2.1.3
 * AUTHOR
        25.07.2008 galina
 * BASES
        BANK COMM       
 * CHANGES
        28.07.2008 galina - добавлено указание баз для подключения
*/


{global.i}
{pk.i}

def var pk-rateq as char no-undo.
def var pknew-rateq as char no-undo.

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def shared frame pkank. 

{pkanklon.f}

if lookup(pkanketa.sts, "03,04,10,20") > 0 then do:
    do transaction on error undo, retry:
    
      find current pkanketa exclusive-lock.
      pk-rateq = string(pkanketa.rateq). 
      update pkanketa.rateq with frame pkank.
      pknew-rateq = string(pkanketa.rateq).
    
      run pkhis.
      find current pkanketa no-lock.
      
    end.
end.
else do: 
  message skip "Невозможно изменить ставку!" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.    

procedure pkhis.
    create pkankhis.
    assign pkankhis.bank = s-ourbank
           pkankhis.credtype = s-credtype
           pkankhis.ln = s-pkankln
           pkankhis.type = 'rateq'
           pkankhis.chval = pk-rateq
           pkankhis.who = g-ofc
           pkankhis.whn = g-today
           pkankhis.rescha[1] = pknew-rateq.
end procedure.


