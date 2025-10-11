import { LightningElement, wire } from 'lwc';
import getAllProducts from '@salesforce/apex/ProductController.getProducts'
export default class ProductList extends LightningElement {

    @wire(getAllProducts) products;
    // { data, error }
    // products.data = List of Products
    // products.error;
}