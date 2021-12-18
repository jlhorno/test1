<%@page import="com.beetext.flow2.data.invoice.*"%>
<%@page import="org.owasp.encoder.Encode"%>
<%@include file="/include/global_inc.jsp"%>

<%
    PersistenceManager pm = FlowPMF.getPM();
	String lineId = request.getParameter("line_id");
	Collection lineDetails = null;
    InvoiceLine invLine = (InvoiceLine)CommonAccess.getObjectById(lineId, true, pm)
%>

<flow:iframe
	request="<%=request%>"
>
<%
	if(lineId != null){
		lineDetails = invLine.getLineDetails();
	}
	if(lineId != null && lineDetails != null){
		double total = 0;
%>
<br/>
<table cellpadding='0' cellspacing='0' width='100%'>
	<tr>
	<td style="width:10"></td>
	<td>
	<table cellpadding='0' cellspacing='1' width='100%' style="background-color:#000000">
		<tr class='rs_top'>
			<td><strong><%=label.getString("service")%></strong></td>
			<td>&nbsp;</td>
			<td align='right'><strong><%=label.getString("quantity")%></strong></td>
			<td align='right'><strong><%=label.getString("price")%></strong></td>
			<td align='right'><strong><%=label.getString("total")%></strong></td>
		</tr>
		
<%		int i = 0;
		for(Iterator it = lineDetails.iterator();it.hasNext();){
			InvoiceLineDetail ld = (InvoiceLineDetail)it.next();
			total += ld.getTotal();%>
		<tr	class='rs_<%=i%2%>'>
			<td>
			<%if(ld.getService() != null){%>
			<%=Encode.forHtml(ld.getService().getName().getValue(lang))%>
			<%}else if(ld.getTextToDisplay() != null){%>
			<%=Encode.forHtml(ld.getTextToDisplay().getValue(lang))%>
			<%}%>
			</td>
			<td>
<%			boolean commaNeeded = false;
			boolean colonNeeded = false;
			if(ld.getSrc()!=null && ld.getTgt()!=null){
				out.write(label.getString("src")+colon+"&nbsp;" + Encode.forHtml(ld.getSrc().getName().getValue(lang)) + " --> " + label.getString("tgt")+colon+" " + Encode.forHtml(ld.getTgt().getName().getValue(lang)));
				colonNeeded = true;
			}
			if(ld.getUnit()!=null){
				out.write(((colonNeeded)?colon+"&nbsp;":"") + Encode.forHtml(Encode.forHtml(ld.getUnit().getName().getValue(lang))));
				colonNeeded = false;
				commaNeeded = true;
			}
			if(ld.getPriority()!=null){
				out.write(((commaNeeded)?", ":"") + Encode.forHtml(ld.getPriority().getName().getValue(lang)));
				commaNeeded = true;
			}
			if(ld.getDomain()!=null){
				out.write(((commaNeeded)?", ":"") + Encode.forHtml(ld.getDomain().getName().getValue(lang)));
				commaNeeded = true;
			}
			if(ld.getCategory()!=null){
				out.write(((commaNeeded)?", ":"") + Encode.forHtml(ld.getCategory().getName().getValue(lang)));
				commaNeeded = true;
			}
%>
			</td>
			<td align='right'><%=FlowFormats.formatUnitQty(ld.getQty())%></td>
			<td align='right'><%=FlowFormats.formatDouble(ld.getPrice(), FlowFormats.getFormat("#,###,##0.00#",','))%></td>
			<td align='right'><%=FlowFormats.formatDouble(ld.getTotal(), FlowFormats.getFormat("#,###,##0.00",','))%></td>
		</tr>
<%			i++;
		}%>
		
		<tr class='rs_top'>
			<td colspan='4'><strong><%=label.getString("total")%></strong></td>
			<td align='right'><strong><%=FlowFormats.formatDouble(total, FlowFormats.getFormat("#,###,##0.00",','))%></strong></td>
		</tr>
	</table>
	</td>
	<td style="width:10"></td>
	</tr>
	<%if(request.getParameter("hide_button") == null){%>
    <tr>
        <td></td>
        <td align="right">
            <input type="button" value="<%=label.getString("add.to.total.field")%>" onclick="fct_addToTotalField()" />
        </td>
        <td></td>
    </tr>
    <%}%>
</table>
<form name="frm_addToTotalField" action="invoicing_action.jsp" method="post">
    <input type="hidden" name="total" value="<%=total%>" />
    <input type="hidden" name="user_action" value="<%=InvoiceAction.ADD_TO_TOTAL_FIELD%>" />
    <input type="hidden" name="line_id" value="<%=Encode.forHtml(lineId)%>" />
</form>
<%	}else{
		out.write("<strong>" + label.getString("error.occured") + "</strong>");
	}%>
</flow:iframe>
<script type="text/javascript">
    function fct_addToTotalField(){
        document.frm_addToTotalField.submit();
    }
    <%if(request.getParameter("user_action") != null && request.getParameter("user_action").equals(Integer.toString(InvoiceAction.ADD_TO_TOTAL_FIELD))){%>
    window.opener.fct_reload();
    this.close();
    <%}%>
</script>
<%pm.close();%>
