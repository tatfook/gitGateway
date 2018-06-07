--[[
desc: config your routes here.
]]
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

Route.set_api_only(true)

RouteHelper.route(
    -- add your route definitions here
    url("get", "/", "Controller.Home", "index"),
    resources(
        "repositories",
        {
            only = {"show"}
        },
        {
            resources(
                "repo_folders",
                {
                    only = {"create", "delete", "update"},
                    members = {
                        {"post", "move"}
                    }
                }
            )
        }
    )
)
