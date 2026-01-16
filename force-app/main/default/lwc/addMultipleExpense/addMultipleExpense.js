import { LightningElement , track} from 'lwc';
import analyzeExpenditure from '@salesforce/apex/Expense_summary_controller.analyzeExpenditure';
export default class AddMultipleExpense extends LightningElement {
    @track addMultipleExpenses = false;
    @track summaryData = [];
    @track showSummary = false;
    @track showSpinner = false;
    handleMultipleExpensesClick(event){
        this.addMultipleExpenses = true;
    }
    closemodal(){
        this.addMultipleExpenses = false;
    }
    handleAnalyzeExpenditure(){
        this.showSummary = true;
        this.showSpinner = true;
        analyzeExpenditure()
        .then((result=> {
            if(result != null && result != undefined){
                this.summaryData = result;
                this.showSpinner = false;
                console.log('hhhh result '+JSON.stringify(result));
            }
            console.log('hhhh result '+JSON.stringify(result));
        }))
        .catch((error) => {
            console.log('hhhh erooor '+JSON.stringify(error));
            this.showSpinner = false;
        });
    }

}