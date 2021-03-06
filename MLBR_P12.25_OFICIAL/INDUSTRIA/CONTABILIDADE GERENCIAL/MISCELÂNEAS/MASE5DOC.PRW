#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MASE5DOC � Autor �Sandro Albuquerque  � Data �  19/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para retornar a filial + data + hora que a movimenta-���
���          �cao bancaria esta sendo realizada chave campo E5_DOCUMEN    ���
���          �quando a eh inclus�o manual								  ���
�������������������������������������������������������������������������͹��
���Uso       � AP 8.11/R4 ou 10.1 - Especifico Midori                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function MASE5DOC()
                                                                                                     
Local aArea	 := GetArea() // Salva area atual

Local _cRet  := ''
Local _cData := ''
Local _cHora := ''

_cData := StrTran(DTOC(M->E5_DATA),"/","") 	// Retorna data sem as barras 
_cHora := StrTran(time(),":","")           	// Retorna a hora sem os pontos 

_cRet := cFilAnt+' ' +_cData+' '+_cHora		 	// Retorna filial em uso + data + hora da movimenta��o bancaria	

RestArea(aArea) //Restaura o ambiente de arquivo
Return(_cRet)