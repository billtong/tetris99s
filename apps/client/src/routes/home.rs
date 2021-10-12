use yew::prelude::*;
use yew_router::prelude::*;

use crate::routes::AppRoute;

/// Home page
pub struct Home;

impl Component for Home {
    type Message = ();
    type Properties = ();

    fn create(_: Self::Properties, _: ComponentLink<Self>) -> Self {
        Home {}
    }

    fn change(&mut self, _: Self::Properties) -> ShouldRender {
        false
    }

    fn update(&mut self, _: Self::Message) -> ShouldRender {
        true
    }

    fn view(&self) -> Html {
        html! {
            <div class="app">
                <button><RouterAnchor<AppRoute> route=AppRoute::Play classes="app-link" >{"Start"}</RouterAnchor<AppRoute>></button>
            </div>
        }
    }
}
