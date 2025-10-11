import { LightningElement, wire } from 'lwc';
import getAllProducts from '@salesforce/apex/ProductController.getProducts'
import getProductsByProductCode from '@salesforce/apex/ProductController.getProductsByProductCode';

export default class ProductList extends LightningElement {

    filteredProducts;
    errors;
    productCode = 'GC1060';

    @wire(getAllProducts) products;
    // { data, error }
    // products.data = List of Products
    // products.error;

    @wire(getProductsByProductCode,{
        productCode: "$productCode",
        productFamily: 'Simple'
    })
    wiredFilteredProducts({ data, error }){
        if(data){
            this.filteredProducts = data;
            console.log(this.filteredProducts);
        }else if(error){
            this.errors = error;
            console.error(this.errors);
        }
    }
}