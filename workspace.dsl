workspace "Quiz Booking System" "Event Driven Architecture" {

    model {
        user = person "User"
        
      
        MYSQLDB = softwareSystem "AWS Aurora" "RDBMS as a service" "External System, Database"
        AWSS3 = softwareSystem "AWS S3" "Cloud Blob Storage" "External System"
        AWSDynamoDb = softwareSystem "AWS DynamoDB" "nosql Database with DX accelarator" "External System, Database"
        AWSCognito = softwareSystem "AWS Cognito" "User pool and authentication" "External System"
        AWSSQS = softwareSystem "AWS SQS" "Message Queue" "External System"
        AWSPinpoint = softwareSystem "AWS Pinpoint" "Multichannel marketing communication service" "External System"
        OpenSearch = softwareSystem "OpenSearch" "AWS Open search service"
        EventStoreDB = softwareSystem "EventstoreDB" "Cloud service for event store" "External System,
        Redis = softwareSystem "Redis" "In memory Storage" "External System,
        ApachePulsar = softwareSystem "Apache Pulsar" "Messaging system" "External System,
        Stripe = softwareSystem "Stripe checkout" "Payment Gateway" "External System,
        
            notification = softwareSystem "Notification Backend Service" {
             notficationservice = container "Notification Service" {
                
                -> ApachePulsar "Subscribe to Notification topic"
                -> AWSPinpoint "Send out email with replacing values in email templates "
                
            }
                
            }
            
        UserApp = softwareSystem "User Application" {
        
            Backend = container "User Service" {
                -> MYSQLDB "Writes email and sub ID"
                -> AWSCognito "Validate JWT Token & fetch from Profile Info from Cognito using SDK"
                -> Redis "Saves user information and renders from cache using SDK"
                
            }
            Frontend = container "User app Front End" {
                user -> this "navigates via client identity.quiz.com"
                -> AWSCognito "Register and Authenticate get JWT Token using SDK"
                -> Backend "Uses REST call with JWT token to Get Profile Information"
                
            }
            AWSCognito -> ApachePulsar "Writes to User registration using Post Sign upLambda"

             ApachePulsar -> Backend "Consume User registration events by establish TCP connection"

        }
        
        
            project = softwareSystem "Projection Service" {
                -> MYSQLDB "Subscribe to Order Events and project to"
            }
            
            EventStoreDB -> project "Subscribe & Project Events to Mysql DB"
            
        Course = softwareSystem "Course Booking Application" {
        
            CourseService = container "Course Booking Service" {
                -> AWSCognito "Validate JWT Token"
                -> AWSDynamoDb "Writes course data and read by Course ID using SDK"
                -> OpenSearch " fetch search Data using SDK"
                -> Redis "Cart management saves & renders from cache using SDK"
                -> EventStoreDB "Publish to Order Intiated status Order topics using REST POST call "
                
            }

            CourseApp = container "Course Booking Front end" {
                user -> this "user navigate / redirect upon registration to course.quiz.com"
                -> CourseService "Uses JWT token Get Profile Information using REST API call"
                
            }
            UserApp -> Course "user navigate / redirect upon registration to course.quiz.com"

        }
        
        Payment = softwareSystem "Payment Application" {
        
            PaymentService = container "Payment Service" {
                -> AWSCognito "Validate JWT Token"
                -> ApachePulsar "Produce Message to Notification Topic"
                -> EventStoreDB "Publish to Payment Recived status "
                
            }
            Stripe -> PaymentService "Payment Success notification webhook"
            PaymentApp = container "Payment Front end" {
                user -> this "User Navigates to payment.quiz.com once order intiated "
                -> Stripe "Redirect to Payment gateway"
                -> PaymentService "Check for payment success/failure status and show to user"
                
            }
            
            Course -> PaymentApp "User Navigates to payment.quiz.com once order intiated "

        }  
        
            Quiz = softwareSystem "Quiz Management Application" {
        
            QuizService = container "Quiz Service" {
                -> AWSCognito "Validate JWT Token"
                -> ApachePulsar "Reads the Quiz Reponse and Evaluate it"
                -> AWSDynamoDb "Writes quiz data and read by quiz data SDK uses DX"
                -> EventStoreDB "Publish to Quiz Results using TCP"
            }
            
            QuizResultService = container "Quiz Result Service" {
                -> EventStoreDB "Subscribe to Quiz Results Events to publish immediately to frontend"
            }


            QuizApp = container "Quiz Front end" {
                user -> this "User Navigates to test.quiz.com once order login and course purchased "
                -> ApachePulsar "Users' quiz responses are published as messages to Quiz Topic"
                -> QuizResultService "Websocket Connection established to get Quiz results"
                
            }
            

        }
        
        
        live = deploymentEnvironment "Live" {
            deploymentNode "Amazon Web Services" {
                deploymentNode "US-East-1" {
                   cloudfront = infrastructureNode "Cloudfront"
                    route53 = infrastructureNode "Route 53"
                     waf = infrastructureNode "AWS WAF"
                     s3 = infrastructureNode "AWS s3"
                     eks = infrastructureNode "AWS EKS"
                    globalaccelerator = infrastructureNode "AWS global Accelerator"
                    elb = infrastructureNode "Elastic Load Balancer"

                    deploymentNode "PODS" {
                 
                            webApplicationInstance = containerInstance PaymentService
                        
                    }
                    
                        deploymentNode "Bucket" {
                            fronendinstance = containerInstance PaymentApp
                        }
                    
                }
               
                deploymentNode "US-West-2" {
                   cloudfront1 = infrastructureNode "Cloudfront"
                    route531 = infrastructureNode "Route 53"
                     waf1 = infrastructureNode "AWS WAF"
                     s31 = infrastructureNode "AWS s3"
                     eks1 = infrastructureNode "AWS EKS"
                    globalaccelerator1 = infrastructureNode "AWS global Accelerator"
                    elb1 = infrastructureNode "Elastic Load Balancer"

                    deploymentNode "PODS" {
                 
                            webApplicationInstance1 = containerInstance PaymentService
                        
                    }
                    
                        deploymentNode "Bucket" {
                            fronendinstance1 = containerInstance PaymentApp
                        }
                    
                }   
                
                
            }
            
            
            
            route53 -> globalaccelerator "Alias target to"
            globalaccelerator -> elb "redirect https request"
            route53 -> cloudfront "alias"
            cloudfront -> s3 "s3 static fronend websites"
            s3 ->  fronendinstance "renders page"
            elb -> eks "round robin routing  and failover to single region when unhealthy cluster using ELB rule "
            eks -> webApplicationInstance "Ingress Forwards requests to" "Container"
            
             route531 -> globalaccelerator1 "Alias target to"
            globalaccelerator1 -> elb1 "redirect https request"
            route531 -> cloudfront1 "alias"
            cloudfront1 -> s31 "s3 static fronend websites"
            s31 ->  fronendinstance1 "renders page"
            elb1 -> eks1 "round robin routing  and failover to single region when unhealthy cluster using ELB rule "
            eks1 -> webApplicationInstance1 "Ingress Forwards requests to" "Container"
        }
        
    }

    views {
     deployment  UserApp live {
            include *
            autoLayout lr

        }

       deployment  Payment live {
            include *
            autoLayout lr

        }
      deployment  Course live {
            include *
            autoLayout lr

        }
        
      deployment  Quiz live {
            include *
            autoLayout lr

        }
        systemContext UserApp {
            include Course
            autolayout lr
        }

        container UserApp {
            include *
            autolayout lr
        }
        systemContext Course {
            include UserApp
            autolayout rl
        }

        container Course {
            include *
            autolayout rl
        }
        systemContext project {
            include EventStoreDB
            include MYSQLDB
            autolayout rl
        }
        systemContext Payment {
            include Course
            autolayout rl
        }
        container Payment {
            include *
            exclude Course
            autolayout lr
        }

        systemContext Quiz {
            include *
            autolayout lr
        }

        container Quiz {
            include *
            autolayout lr
        }
        
        
        container notification {
            include *
            autolayout lr
        }
        
        
        theme default
        
    }

}
