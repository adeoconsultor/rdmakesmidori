/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MAGPC02   �Autor  �PrimaInfo           � Data �  05/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Nao considerar dias de licenca remunerada para ferias      ���
���          � normais                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP10 - Midori                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MAGPC02()

IF FunName() = "GPEM030"
	M->RH_DIALRE1 := 0
	M->RH_DIALREM := 0
Endif

Return