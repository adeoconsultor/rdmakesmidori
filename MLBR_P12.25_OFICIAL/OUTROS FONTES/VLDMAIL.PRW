#INCLUDE "RWMAKE.ch"    
#INCLUDE "TOPCONN.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa �VLDMAIL     �Autor: Diego Mafisolli      � Data � 27/10/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function DM_VLDMAIL(cEmail)
local nCont := 1
local lRet   := .T.
local nResto := 0
  
If cEmail $ "{}()<>[]|\/&*$%?!^~`,:=# "
	APMSGALERT("Email inv�lido. Informe um endere�o de e-mail v�lido.","Atencao") 
	lRet := .F.

else

	if ( nResto := at( "@", cEmail )) > 0 .and. at( "@", right( cEmail, len( cEmail ) - nResto )) == 0 
	
	     if ( nResto := at( ".", right( cEmail, len( cEmail ) - nResto ))) > 0 
	
	        lRet := .T.
	
	     else
	
	        APMSGALERT("Email inv�lido. Informe um endere�o de e-mail v�lido.","Atencao") 
	
	        lRet := .F. 
	
	    endif
	
	else

     APMSGALERT("Email inv�lido. Informe um endere�o de e-mail v�lido.","Atencao")  

     lRet := .F. 

	endif

endif


return lRet