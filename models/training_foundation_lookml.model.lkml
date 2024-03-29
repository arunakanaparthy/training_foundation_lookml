# Define the database connection that should be used for this model.
connection: "snowlooker"

# include all the views
include: "/views/**/*.view"

# Default caching policy for the Explores.  These will be covered later, but if you are curious now, use the Quick Help
# panel on the right to check out our documentation!
datagroup: training_foundation_lookml_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_foundation_lookml_default_datagroup

access_grant: privileged_departments {
  user_attribute: department
  allowed_values: ["hr", "finance", "Admin"]
}


######## Building Explores: ########

# Explores allow you to join together different views (database tables) based on
# relationships between fields. By adding a view into an Explore, you make those
# fields available to users for data analysis.
# Explores should be purpose-built based on use cases.

# For example, to make the distribution_centers view available to users,
# you can define the following Explore:

explore: distribution_centers {}


# Let's talk about joining.  To create more sophisticated that involve multiple
# views, you can use the join parameter. Typically, join parameters require that
# you define the join type, a sql_on clause , and the view relationship.

# For example, the order_items Explore below joins together order, user, and
# product views to provide users insight into sales and company performance.

# The explore beings with the order_items view.
explore: order_items {

# Next, you define the view that should be joined to order_items, which is the orders view in this case.
  join: users {

# The join criteria is inserted by defining the type, sql_on, and relationship
# parameters.
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    #required_access_grants: [privileged_departments]
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

  join: order_facts_ndt {
    type: left_outer
    sql_on: ${order_items.order_id}  = ${order_facts_ndt.order_id};;
    relationship: many_to_one
  }
}

# Now you try!
# Exercise: Building Explores
#           Create a new Explore that enables you to analyze users and the items that they have ordered.
#           You can do this by joining together the users view and the order_items view.





# Bonus question: Why might you build this second Explore that starts with the users view when
# you already have users and order_items joined together within the order_items Explore?





######## Solutions ########


# Solution: Building Explores

# explore: users {
#   join: order_items {
#     type: left_outer
#     sql_on: ${users.id} = ${order_items.user_id}  ;;
#     relationship: one_to_many
#   }
# }


# Bonus Answer: Starting an Explore with the users view will allow you to capture all users, not just
# those who have placed orders (and you won't have to use an full_outer join to do it!).  This could
# be used to support cohort analysis, purchasing patterns, and other user-focused analytics.
