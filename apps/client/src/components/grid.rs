use yew::{Component, ComponentLink, Properties};
use yew::prelude::*;

/// Grid component
pub struct Grid {
    props: GridProps,
}

#[derive(Properties, Clone)]
pub struct GridProps {
    #[prop_or(true)]
    pub active: bool,
}

impl Component for Grid {
    type Message = ();
    type Properties = GridProps;

    fn create(props: GridProps,  _: ComponentLink<Self>) -> Self {
        Grid { props }
    }

    fn change(&mut self, props: Self::Properties) -> ShouldRender {
        self.props = props;
        true
    }

    fn update(&mut self, _: Self::Message) -> ShouldRender {
        true
    }

    fn view(&self) -> Html {
        html! {
            <div>
                <canvas>{"Oops! Your browser does not support canvas :("}</canvas>
            </div>
        }
    }
}
