import { LightningElement, track, api } from 'lwc';
import saveFiles from '@salesforce/apex/FileUploadController.saveFiles';

// import uploadFile from '@salesforce/apex/CustomFileUploadLWCCtrl.uploadFile';
// import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class UploadMultiplefile extends LightningElement {

    @api
    recordId;
    @track fileUploaded = false; // Render template
    @track fileNamesArr = []; // Display file names
    filesArr = []; // Store read file objects to pass to Apex
    filePromises = []; // Called my Promise.all
    @track showSpinner = true;
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.tiff'];
    }
    // Handles front end; build FileReader object in a helper and call apex
    handleAddFiles(event) {
        if (event.target.files.length > 0) {
            // Validate file size
            for(let i = 0; i < event.target.files.length; i++) {
                let file = event.target.files[i]
                if(file.size > 1000000 ) {
                    // console.log('File too large, size: ' + file.size)
                    this.throwError(this.label.fileSizeError + ' ' + file.name); // Custom labels used
                    return;
                }
            }
            this.fileUploaded = true; // Show element
            if (this.isIdentificationRequired) { // Condition for multiple files
                for (let i = 0; i < event.target.files.length; i++) {
                    let file = event.target.files[i];
                    this.fileNamesArr.push({Name: file.name}); // Iterate html
                    this.filesArr.push(file);
                }
            } else { // Single file upload
                let file = event.target.files[0];
                this.fileNamesArray = [];
                this.fileNamesArr.push({Name: file.name});
                this.filesArr.push(file);
            }
        }
    }
    
    // Called by Submit button
    buildFile() { 
        for (let i = 0; i < this.filesArr.length; i++) {
            let build = new Promise((resolve, reject) => {
                    let freader = new FileReader();
                    freader.readAsDataURL(this.filesArr[i]); // reads file contents
                    freader.onload = f => {    // executes after successful read
                        let base64 = 'base64,';
                        let content = freader.result.indexOf(base64) + base64.length;
                        let fileContents = freader.result.substring(content);
                        resolve({ // returns a value after successful promise
                            Title: this.filesArr[i].name, // Store file name
                            VersionData: fileContents
                        })
                    };
                })
            this.filePromises.push(build); // filePromises called by Promise.all()
        }
        return Promise.all(this.filePromises) // Execute all file builds asynchronously
        .then(result => {
            this.handleSaveFiles(this.recordId, result) // Pass file objects to Apex
        }) 
    }
    removeFiles(event)
    {
        this.fileUploaded = false;
        this.showSpinner = false;
        this.files = undefined; 
        this.fileNamesArr = []; 
        this.filesArr = [];
        this.filesUploaded = [];
    }
    handleSaveFiles(recordId, result) 
    {
        console.log('handleSaveFiles recordId: ' + recordId);
        saveFiles({ recordId: recordId, filesToInsert: result})
        .then(data => {            
            const showSuccess = new ShowToastEvent({
                title: this.label.success, // Custom label use
                message: this.fileNamesArr.length + ' ' + this.label.fileUploadSuccess,
                variant: 'Success',
            });
            this.dispatchEvent(showSuccess); 
            this.fileNamesArray = [];
        })
        .catch(error => {
            const showError = new ShowToastEvent({
                title: 'Error!!',
                message: 'An Error occur while uploading the file. ' + error.message,
                variant: 'error',
            });
            this.dispatchEvent(showError);
        });
    }


    // @track showSpinner = false;
    // @track fileData;
    // @api recordId;
    // @track fileName;
    //  // getting file 
    // handleFileChange(event) {
    //     if(event.target.files.length > 0) {
    //         const file = event.target.files[0]
    //         var reader = new FileReader()
    //         reader.onload = () => {
    //             var base64 = reader.result.split(',')[1]
    //             this.fileName = file.name;
    //             this.fileData = {
    //                 'filename': file.name,
    //                 'base64': base64
    //             }
    //             console.log(this.fileData)
    //         }
    //         reader.readAsDataURL(file)
    //     }
    // }
 
    // uploadFile() {
    //     this.handleSpinner();
    //     const {base64, filename} = this.fileData
 
    //     uploadFile({ fileName:this.fileName, base64Data : base64, recordId:this.recordId }).then(result=>{
    //         this.fileData = null
    //         let title = `${filename} uploaded successfully!!`;
    //         this.ShowToast('Success!', title, 'success', 'dismissable');
    //         this.updateRecordView(this.recordId);
    //     }).catch(err=>{
    //         this.ShowToast('Error!!', err.body.message, 'error', 'dismissable');
    //     }).finally(() => {
    //         this.handleSpinner();
    //     })
    // }
 
    // handleSpinner(){
    //     this.showSpinner = !this.showSpinner;
    // }
 
    // ShowToast(title, message, variant, mode){
    //     const evt = new ShowToastEvent({
    //         title: title,
    //         message:message,
    //         variant: variant,
    //         mode: mode
    //     });
    //     this.dispatchEvent(evt);
    // } 
 
    // //update the record page
    // updateRecordView() {
    //    setTimeout(() => {
    //         eval("$A.get('e.force:refreshView').fire();");
    //    }, 1000); 
    // }

}