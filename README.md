# GoCase API [![Build Status](https://travis-ci.org/aranhaqg/go_case_challenge.svg?branch=master)](https://travis-ci.org/aranhaqg/go_case_challenge)

Rails REST API to receive Purchase Orders, group them on Batches, follow the Orders in the production pipeline until the dispatch and generate some simple financial reports.
Available at https://limitless-dusk-21363.herokuapp.com/.

This app uses:

* Ruby version 2.4.1
* Rails 5.2.0
* PostgreSQL 9.6.8

To run tests it was used RSpec, Factory Bot, Shoulda Matchers, Faker and Database Cleaner gems. For more details check [Gemfile](Gemfile).

To check the implemented tests see [Order Spec](/spec/models/order_spec.rb), [Batch Spec](/spec/models/order_spec.rb), [Orders Spec](/spec/requests/orders_spec.rb) and [Batches Spec](/spec/requests/batches_spec.rb)

## Entities
### Order

The [Order](/app/models/order.rb) entity it's composed of the following properties:

* reference: String 
* purchase_channel: String 
* client_name: String 
* address: String
* delivery_service: String
* total_value: Decimal 
* line_items: JSON 
* status: String
* batch_id: Integer (foreign key to reference the Batch entity)
* batch: Batch entity

For Line Items the json object was used to make it's declaration flexible.

This entity validates presence of reference, purchase_channel, client_name, address, delivery_service, line_items, total_value and status. And also validates uniqueness of the given reference.

The reference attribute wasn't formatted in a specific way like in the Batch entity, but it could be in the future if needed. 

### Batch

The [Batch](/app/models/batch.rb) entity it's composed of the following properties:

    * reference: virtual String attribute that is dinamycally mounted based on created_at year, created_at month and id
    * purchase_channel: String
    * orders: list of related Orders

This entity validates presence of purchase channel and validates if orders' batch purchase channel are the same. In a batch we can mix orders of differents purchase channels.   
Since in the description of the challenge It was obvious the pattern in the batch reference I decided to auto-generate it based on the creation date and id of the batch. Since I used the id in the reference, it was easy to query by reference.


### Report Handler
The [Report Handler](/app/models/report_handler.rb) is a PORO to handle the generation and query for reports.

Before deciding to use a PORO I used SimpleDelegator to dinamically mass assing attributes. I realized that due to some errors that I couldt'n resolved in time, it was better to get a simpler and straight foward solution.  


## Modules
These modules above was included at ApplicationController.

### Response

[Response](/app/controllers/concerns/response.rb) was used to give some homogenization to the returns. It setups JSON objecti returned and an HTTP STATUS code 200 by default. 


### Exception Handler
[Exception Handler](/app/controllers/concerns/exception_handler.rb) was used to handle ActiveRecord::RecordNotFound and ActiveRecord::RecordInvalid and returns a JSON and HTTP STATUS response. Any other exception can be catch and treated there.



## Endpoints
All defined endpoints returns a JSON Object (a message or requested entities).

### GET /orders

This endpoint is used to returns the orders and its handled by action index at [Orders Controller](/app/controllers/orders_controller.rb). 
The orders can be filtered by client_name, purchase_channel, status, limit and offset. The limit and offset was used to give the user a way to limit the orders retrived. 

All these filters can be used to: paginate the results, list order by purchase channel, list orders by client name and/or list by status. 

If any order is found with the given params, a response with the serialized orders with all class attributes (including order status) and batch reference(only when batch id is not null) and status code 200. If no order was found, a no order found message error and 400 status code are expected.

### GET /batches/:batch_id/orders

This endpoint is used to retrieve orders from a specific batch ans its handled by action orders at [Batches Controller](/app/controllers/batches_controller.rb). If the batch was found, the batch orders and statud code 200 are expected. If no batch was found, returns a no batch found error messade and 404 status code.

### POST /orders 

This endpoint is used to create a new order and its handled by action index at [Orders Controller](/app/controllers/orders_controller.rb).
This action expect to receive the valid attributes and returns http status code 200. If not, it should return a response with the attribute error message and status code 422. 

### PUT /orders/:id

This endpoint is used to update a order and its handled by action update at [Orders Controller](/app/controllers/orders_controller.rb).
This action expects to receive the valid attributes that should be updated and returns http status code 204. If not, it should return a response with the attribute error message and status code 422. 
This action can be used to modify orders in production.

### GET /batches
This endpoint is used to returns the batches and its handled by action index at [Batches Controller](/app/controllers/batches_controller.rb). 

The batches can be filtered by id and reference. 

If any batch is found with the given params, a response with the serialized batches and status code 200 will be returned. If no order was found, a no order found message error and 400 status code are expected.

### POST /batches

This endpoint is used to create a new batch and it's handled by action create at [Batches Controller](/app/controllers/batches_controller.rb).
This action expects to receive a purchase channel and orders_ids as valid attributes and returns the batch reference and number of associated orders. If the params were not valid, it returns a 422 status code and error message.

### PUT /batches/:id

This endpoint is used to update a batch and its handled by action update at [Batches Controller](/app/controllers/batches_controller.rb). 
This action expects to receive a purchase channel, a status and/or a delivery service. 

The update action can be use to produce a batch or close part of a batch for a delivery service for example.

If the attributes are valid, a status code 204 is expected. If not, a error message and a 404 status code for batch not found.

### GET /reports/ 

This endpoint is used to return a report json object with a list of purchase channel with theirs orders, number of orders and total value per channel.

These orders can be filteres by purchase channel. If any order is found for the given channel, the report and status code 200 are returned. If no order was found, a no orders found error message and 404 status code are expected.

## Future Improvements

* Use ActiveModel Serializer to handle better serialization/deserialization.
* Implement authentication and authorization.
* Improve security with Rack Attack to protect from bad clients. Can be used to prevent brute-force passwords attacks, scrapers and throttling requests from IP addresses for example.
* Scan code to look for security vulnerabilities with Brakeman. 
* Use Command Pattern to improve performance at Controllers
* Make Reports more queryble (e.g. search by client_name, order_satus, delivery service or batch_reference)
* Refactor ReportHandler to improve legibility and flexibility.
* Add another filters for batches like delivery service or limit and offset.
* Add a Web UI to the app






